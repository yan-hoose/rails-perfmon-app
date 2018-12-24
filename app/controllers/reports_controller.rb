class ReportsController < ApplicationController
  layout 'application', only: [:dashboard]
  before_action :set_website, except: [:dashboard]
  before_action :set_result_data, only: [:overview, :request_durations, :db_time, :view_time,
    :avg_request_duration_chart, :db_time_chart, :view_time_chart, :nr_of_requests_chart]
  before_action :set_blocker_result_data, only: [:blockers, :blocker_count_chart]

  def dashboard
    @reports = {}
    current_user.websites.each do |website|
      @reports[website.id] = ReportsDataGatherer.new(website,
        {dashboard: 'true', start_date: Date.today - 2.days, end_date: Date.today, compare_periods: false, contr: '', act: ''},
        session)
    end
  end

  def overview
    @result_data.select_fields(sort_order: 'COUNT(id) DESC', attributes: [:hits]) do
      select('controller, action, COUNT(id) AS hits').group('controller, action').limit(15)
    end
    @http_methods = @result_data.group(:method).count
    @http_statuses = @result_data.group(:status).count
  end

  def request_durations
    @result_data.select_fields do
      select('controller, action, COUNT(id) AS hits, SUM(total_runtime) AS sum,
        AVG(total_runtime) AS avg, MIN(total_runtime) AS min, MAX(total_runtime) AS max').
        group('controller, action')
    end
  end

  def db_time
    @result_data.select_fields do
      select('controller, action, COUNT(id) AS hits, SUM(db_runtime) AS sum,
        AVG(db_runtime) AS avg, MIN(db_runtime) AS min, MAX(db_runtime) AS max').
        group('controller, action')
    end
  end

  def view_time
    @result_data.select_fields do
      select('controller, action, COUNT(id) AS hits, SUM(view_runtime) AS sum,
        AVG(view_runtime) AS avg, MIN(view_runtime) AS min, MAX(view_runtime) AS max').
        group('controller, action')
    end
  end

  def blockers
    @result_data.select_fields(sort_order: 'COUNT(id) DESC', attributes: [:count]) do
      select('controller, action, COUNT(id) AS count').group('controller, action')
    end
    @overall_blocker_count = @result_data.tabular_data.inject(0) { |sum, row| sum + row.count }
  end

  def nr_of_requests_chart
    render json: @result_data.chart_data('COUNT(id) AS hits')
  end

  def avg_request_duration_chart
    render json: @result_data.chart_data('AVG(db_runtime)::int AS avg_db_runtime, AVG(view_runtime)::int AS avg_view_runtime,
      AVG(total_runtime - db_runtime - view_runtime)::int AS avg_other_runtime, AVG(total_runtime)::int AS avg_total_runtime',
      'AVG(total_runtime)::int AS avg_total_runtime')
  end

  def db_time_chart
    render json: @result_data.chart_data('AVG(db_runtime)::int AS avg_db_runtime')
  end

  def view_time_chart
    render json: @result_data.chart_data('AVG(view_runtime)::int AS avg_view_runtime')
  end

  def blocker_count_chart
    render json: @result_data.chart_data('COUNT(id) AS count')
  end

private

  def set_website
    @website = @current_user.websites.find(params[:website_id])
  end

  def set_result_data
    @result_data = ReportsDataGatherer.new(@website, params, session)
  end

  def set_blocker_result_data
    @result_data = ReportsDataGatherer.new(@website, params, session, 'total_runtime >= 1000')
  end

end
