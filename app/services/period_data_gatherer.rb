class PeriodDataGatherer
  attr_reader :tabular_data
  delegate :group, to: :@filtered_rows

  def initialize(website, filters, additional_filtering_conditions = nil)
    @website = website
    @filters = filters
    @additional_filtering_conditions = additional_filtering_conditions
    @filtered_rows = get_filtered_rows
  end

  def generate_tabular_data(sort_order = nil, &block)
    @tabular_data = @filtered_rows.instance_eval(&block).order(sort_order)
  end

  def chart_data(select_fields)
    @filtered_rows.select("EXTRACT(EPOCH FROM DATE_TRUNC('hour', time::timestamptz) AT TIME ZONE '#{Time.zone.tzinfo.identifier}') AS timespan, #{select_fields}").
      group('timespan').order('timespan')
  end

  def total_hits
    @total_hits ||= @filtered_rows.count
  end

  def requests_per_minute
    minutes = (@filters[:end_date] + 1.day - @filters[:start_date]) * 24 * 60
    @requests_per_minute ||= total_hits.to_f / minutes
  end

  def nth_percentile
    unless @nth_percentile
      sub_sql = @filtered_rows.select('total_runtime, (cume_dist() OVER (ORDER BY total_runtime)) AS percentile').to_sql
      @nth_percentile = Request.count_by_sql %Q{
        WITH runtimes AS (#{sub_sql})
        SELECT total_runtime::int
        FROM runtimes
        WHERE percentile >= 0.95
        LIMIT 1
      }
    end
    @nth_percentile
  end

  private

  def get_filtered_rows
    requests = @website.requests.where('time >= ? AND time < ?', @filters[:start_date].in_time_zone, @filters[:end_date].in_time_zone + 1.day)
    requests = requests.where(controller: @filters[:contr]) if @filters[:contr].present?
    requests = requests.where(action: @filters[:act]) if @filters[:act].present?
    requests = requests.where(@additional_filtering_conditions) if @additional_filtering_conditions
    requests
  end

end
