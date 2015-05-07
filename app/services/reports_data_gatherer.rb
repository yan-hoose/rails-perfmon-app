class ReportsDataGatherer
  attr_reader :comparison_data_hash, :filters
  delegate :tabular_data, :total_hits, :requests_per_minute, :nth_percentile, :group, to: :@current_period_data

  def initialize(website, params, session, additional_filtering_conditions = nil)
    @website = website
    @filters = get_filters(session, params)

    @current_period_data = PeriodDataGatherer.new(@website, @filters, additional_filtering_conditions)

    if @filters[:compare_periods]
      @comparison_period_data = PeriodDataGatherer.new(@website,
        @filters.merge(start_date: @filters[:comparison_start_date], end_date: @filters[:comparison_end_date]),
        additional_filtering_conditions)
    end
  end

  def select_fields(sort_order: nil, attributes: [:hits, :sum, :avg, :min, :max], &block)
    @current_period_data.generate_tabular_data(sort_order, &block)

    if @filters[:compare_periods]
      @comparison_period_data.generate_tabular_data(sort_order, &block)
      generate_comparison_data_hash(attributes)
    end
  end

  def chart_data(select_fields, comparison_select_fields = nil)
    comparison_select_fields = select_fields unless comparison_select_fields
    {
      data: @current_period_data.chart_data(@filters[:compare_periods] ? comparison_select_fields : select_fields),
      comparison_data: @filters[:compare_periods] ? @comparison_period_data.chart_data(comparison_select_fields) : nil
    }
  end

  def comparison
    @comparison_period_data
  end

  private

  def get_filters(session, params)
    filters_key = params[:dashboard] == 'true' ? :dashboard_query_filters : :query_filters

    session[filters_key] ||= {}

    compare_periods = params[:compare_periods] || session[filters_key][:compare_periods]

    session[filters_key] = {
      start_date: set_date_filter_value(params[:start] || session[filters_key][:start_date], Date.today - 7.days),
      end_date: set_date_filter_value(params[:end] || session[filters_key][:end_date], Date.today),
      compare_periods: compare_periods.is_a?(String) ? compare_periods == 'true' : compare_periods,
      comparison_start_date: set_date_filter_value(params[:comparison_start] || session[filters_key][:comparison_start_date], Date.today - 14.days),
      comparison_end_date: set_date_filter_value(params[:comparison_end] || session[filters_key][:comparison_end_date], Date.today - 8.days),
      contr: params[:contr] || session[filters_key][:contr],
      act: params[:act] || session[filters_key][:act]
    }
  end

  def set_date_filter_value(date, default_date)
    date.blank? ? default_date : date.to_date
  end

  def generate_comparison_data_hash(attributes)
    @comparison_data_hash = {}
    @comparison_period_data.tabular_data.each do |row|
      @comparison_data_hash[row.controller] ||= {}
      @comparison_data_hash[row.controller][row.action] = {}
      attributes.each do |attr|
        @comparison_data_hash[row.controller][row.action][attr] = row.send(attr)
      end
    end
  end

end