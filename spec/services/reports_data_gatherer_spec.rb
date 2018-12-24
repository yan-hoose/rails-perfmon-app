require "rails_helper"

RSpec.describe ReportsDataGatherer do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @website = FactoryGirl.create(:website)
    FactoryGirl.create(:users_website, user: @user, website: @website)
  end
  let(:params) { {} }
  let(:session) { {} }

  describe '#initialize' do
    let(:default_filters) {
      {
        start_date: Date.today - 7.days,
        end_date: Date.today,
        compare_periods: nil,
        comparison_start_date: Date.today - 14.days,
        comparison_end_date: Date.today - 8.days,
        contr: nil,
        act: nil
      }
    }

    it 'creates filters hash' do
      gatherer = ReportsDataGatherer.new(@website, params, session)
      expect(gatherer.filters).to_not be_nil
    end

    it 'creates current period data gatherer' do
      expect(PeriodDataGatherer).to receive(:new).once.with(@website, default_filters, nil)
      gatherer = ReportsDataGatherer.new(@website, params, session)
    end

    it 'creates current period data gatherer with additional filtering conditions' do
      expect(PeriodDataGatherer).to receive(:new).once.with(@website, default_filters, 'this >= that')
      gatherer = ReportsDataGatherer.new(@website, params, session, 'this >= that')
    end

    it 'creates previous period data gatherer if comparing periods' do
      expect(PeriodDataGatherer).to receive(:new).once.with(@website, default_filters.merge(compare_periods: true), nil)
      expect(PeriodDataGatherer).to receive(:new).once.with(@website,
        default_filters.merge(start_date: Date.today - 14.days, end_date: Date.today - 8.days, compare_periods: true),
      nil)
      gatherer = ReportsDataGatherer.new(@website, params.merge(compare_periods: true), session)
    end
  end

  describe '#select_fields' do
    it 'runs #generate_tabular_data on @current_period_data' do
      gatherer = ReportsDataGatherer.new(@website, params, session)

      expect(gatherer.instance_variable_get(:@current_period_data)).
        to receive(:generate_tabular_data).with('max ASC', any_args).and_call_original

      gatherer.select_fields(sort_order: 'max ASC') do
        select('controller, action, MAX(total_runtime) AS max').group('controller, action')
      end
      expect(gatherer.tabular_data).to_not be_nil
    end

    it 'runs #generate_tabular_data on @comparison_period_data and generates comparison hash when comparing periods' do
      gatherer = ReportsDataGatherer.new(@website, params.merge(compare_periods: true), session)

      expect(gatherer.instance_variable_get(:@current_period_data)).to receive(:generate_tabular_data).once
      expect(gatherer.instance_variable_get(:@comparison_period_data)).
        to receive(:generate_tabular_data).once.with('max ASC', any_args).and_call_original
      expect(gatherer).to receive(:generate_comparison_data_hash).with([:max])

      gatherer.select_fields(sort_order: 'max ASC', attributes: [:max]) do
        select('controller, action, MAX(total_runtime) AS max').group('controller, action')
      end
      expect(gatherer.instance_variable_get(:@comparison_period_data).tabular_data).to_not be_nil
    end

    describe '@comparison_data_hash creation' do
      it 'loads comparison data and creates @comparison_data_hash when comparing periods' do
        FactoryGirl.create(:request, time: Time.now - 8.days)
        gatherer = ReportsDataGatherer.new(@website, {compare_periods: true, comparison_start: Date.today - 8.days, comparison_end: Date.today - 8.days}, session)

        gatherer.select_fields do
          select('controller, action')
        end
        expect(gatherer.comparison_data_hash).to_not be_nil
      end

      it 'adds comparison request data to @comparison_data_hash' do
        FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'index', db_runtime: 100, time: Time.now - 8.days)
        FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'index', db_runtime: 200, time: Time.now - 8.days)
        FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'update', db_runtime: 50, time: Time.now - 8.days)
        FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'update', db_runtime: 100, time: Time.now - 8.days)
        gatherer = ReportsDataGatherer.new(@website, {compare_periods: true, comparison_start: Date.today - 8.days, comparison_end: Date.today - 8.days}, session)

        gatherer.select_fields do
          select('controller, action, COUNT(id) AS hits, SUM(db_runtime) AS sum, AVG(db_runtime) AS avg, MIN(db_runtime) AS min, MAX(db_runtime) AS max').
            group('controller, action')
        end

        hash = gatherer.comparison_data_hash

        expect(hash['PostsController']).to_not be_nil
        expect(hash['PostsController']['index']).to_not be_nil
        expect(hash['PostsController']['index'][:hits]).to eq(2)
        expect(hash['PostsController']['index'][:sum]).to eq(300)
        expect(hash['PostsController']['index'][:min]).to eq(100)
        expect(hash['PostsController']['index'][:max]).to eq(200)
        expect(hash['PostsController']['index'][:avg]).to eq(150)

        expect(hash['PostsController']['update']).to_not be_nil
        expect(hash['PostsController']['update'][:hits]).to eq(2)
        expect(hash['PostsController']['update'][:sum]).to eq(150)
        expect(hash['PostsController']['update'][:min]).to eq(50)
        expect(hash['PostsController']['update'][:max]).to eq(100)
        expect(hash['PostsController']['update'][:avg]).to eq(75)

        expect(hash['PostsController']['new']).to be_nil
        expect(hash['CommentsController']).to be_nil
      end
    end
  end

  describe '#chart_data' do
    it 'gets chart data' do
      gatherer = ReportsDataGatherer.new(@website, params, session)

      expect(gatherer.instance_variable_get(:@current_period_data)).to receive(:chart_data).with(
        'AVG(db_runtime), AVG(view_runtime)').once.and_call_original

      chart_data = gatherer.chart_data('AVG(db_runtime), AVG(view_runtime)', 'AVG(total_runtime)')
      expect(chart_data).to_not be_nil
      expect(chart_data.has_key?(:data)).to be(true)
      expect(chart_data.has_key?(:comparison_data)).to be(true)
      expect(chart_data[:data]).to eq([])
      expect(chart_data[:comparison_data]).to eq(nil)
    end

    it 'gets chart data with comparison data when comparing periods' do
      gatherer = ReportsDataGatherer.new(@website, {compare_periods: true}, session)

      expect(gatherer.instance_variable_get(:@current_period_data)).
        to receive(:chart_data).with('AVG(total_runtime)').once.and_call_original
      expect(gatherer.instance_variable_get(:@comparison_period_data)).
        to receive(:chart_data).with('AVG(total_runtime)').once.and_call_original

      chart_data = gatherer.chart_data('AVG(db_runtime), AVG(view_runtime)', 'AVG(total_runtime)')
      expect(chart_data).to_not be_nil
      expect(chart_data.has_key?(:data)).to be(true)
      expect(chart_data.has_key?(:comparison_data)).to be(true)
      expect(chart_data[:data]).to eq([])
      expect(chart_data[:comparison_data]).to eq([])
    end

    it 'defaults to first select fields when comparison select fields are not set' do
      gatherer = ReportsDataGatherer.new(@website, {compare_periods: true}, session)

      expect(gatherer.instance_variable_get(:@current_period_data)).
        to receive(:chart_data).with('AVG(db_runtime), AVG(view_runtime)').once.and_call_original
      expect(gatherer.instance_variable_get(:@comparison_period_data)).
        to receive(:chart_data).with('AVG(db_runtime), AVG(view_runtime)').once.and_call_original

      gatherer.chart_data('AVG(db_runtime), AVG(view_runtime)')
    end
  end

  describe '#get_filters' do
    it 'creates filters based on params if params defined' do
      params = {
        start_date: Date.today - 3.days,
        end_date: Date.today,
        compare_periods: true,
        comparison_start: Date.today - 11.days,
        comparison_end: Date.today - 8.days,
        contr: 'PostsController',
        act: 'index'
      }
      gatherer = ReportsDataGatherer.new(@website, params, {})
      expect(gatherer.filters[:start_date]).to eq(params[:start_date])
      expect(gatherer.filters[:end_date]).to eq(params[:end_date])
      expect(gatherer.filters[:compare_periods]).to eq(params[:compare_periods])
      expect(gatherer.filters[:comparison_start_date]).to eq(params[:comparison_start])
      expect(gatherer.filters[:comparison_end_date]).to eq(params[:comparison_end])
      expect(gatherer.filters[:contr]).to eq(params[:contr])
      expect(gatherer.filters[:act]).to eq(params[:act])
    end

    it 'takes filters from the session if params not defined' do
      session[:query_filters] = {
        start_date: Date.today - 5.days,
        end_date: Date.today - 1.day,
        compare_periods: true,
        comparison_start_date: Date.today - 12.days,
        comparison_end_date: Date.today - 8.days,
        contr: 'PostsController',
        act: 'index'
      }
      gatherer = ReportsDataGatherer.new(@website, {}, session)
      expect(gatherer.filters[:start_date]).to eq(session[:query_filters][:start_date])
      expect(gatherer.filters[:end_date]).to eq(session[:query_filters][:end_date])
      expect(gatherer.filters[:compare_periods]).to eq(session[:query_filters][:compare_periods])
      expect(gatherer.filters[:comparison_start_date]).to eq(session[:query_filters][:comparison_start_date])
      expect(gatherer.filters[:comparison_end_date]).to eq(session[:query_filters][:comparison_end_date])
      expect(gatherer.filters[:contr]).to eq(session[:query_filters][:contr])
      expect(gatherer.filters[:act]).to eq(session[:query_filters][:act])
    end

    it 'sets default date filters if not set in params or session' do
      expect_any_instance_of(ReportsDataGatherer).to receive(:set_date_filter_value).exactly(4).times.and_call_original
      gatherer = ReportsDataGatherer.new(@website, {}, {})
      expect(gatherer.filters[:start_date]).to eq(Date.today - 7.days)
      expect(gatherer.filters[:end_date]).to eq(Date.today)
      expect(gatherer.filters[:comparison_start_date]).to eq(Date.today - 14.days)
      expect(gatherer.filters[:comparison_end_date]).to eq(Date.today - 8.days)
    end

    it 'saves filters into the session' do
      gatherer = ReportsDataGatherer.new(@website, params, session)
      expect(gatherer.filters).to eq(session[:query_filters])
    end

    it 'keeps dashboard filters separate from report filters' do
      gatherer = ReportsDataGatherer.new(@website, {dashboard: 'true'}, session)
      expect(gatherer.filters).to be(session[:dashboard_query_filters])
      expect(gatherer.filters).to_not be(session[:query_filters])

      gatherer = ReportsDataGatherer.new(@website, {dashboard: 'false'}, session)
      expect(gatherer.filters).to be(session[:query_filters])
      expect(gatherer.filters).to_not be(session[:dashboard_query_filters])
    end
  end

  describe '#set_date_filter_value' do
    it 'sets date filter value if blank else converts to date' do
      gatherer = ReportsDataGatherer.new(@website, {}, {})
      expect(gatherer.send(:set_date_filter_value, nil, Date.today - 7.days)).to eq(Date.today - 7.days)
      expect(gatherer.send(:set_date_filter_value, '', Date.today - 3.days)).to eq(Date.today - 3.days)

      expect(gatherer.send(:set_date_filter_value, Date.today - 7.days, Date.today)).to eq(Date.today - 7.days)
      expect(gatherer.send(:set_date_filter_value, '2015-03-10', Date.today - 7.days)).to eq(Date.new(2015, 3, 10))
    end
  end

  describe 'delegate' do
    it 'delegates the :tabular_data method to @current_period_data' do
      gatherer = ReportsDataGatherer.new(@website, {}, {})
      expect(gatherer.instance_variable_get(:@current_period_data)).to receive(:tabular_data)
      gatherer.tabular_data
    end

    it 'delegates the :total_hits method to @current_period_data' do
      gatherer = ReportsDataGatherer.new(@website, {}, {})
      expect(gatherer.instance_variable_get(:@current_period_data)).to receive(:total_hits)
      gatherer.total_hits
    end

    it 'delegates the :requests_per_minute method to @current_period_data' do
      gatherer = ReportsDataGatherer.new(@website, {}, {})
      expect(gatherer.instance_variable_get(:@current_period_data)).to receive(:requests_per_minute)
      gatherer.requests_per_minute
    end

    it 'delegates the :nth_percentile method to @current_period_data' do
      gatherer = ReportsDataGatherer.new(@website, {}, {})
      expect(gatherer.instance_variable_get(:@current_period_data)).to receive(:nth_percentile)
      gatherer.nth_percentile
    end

    it 'delegates the :group method to @current_period_data' do
      gatherer = ReportsDataGatherer.new(@website, {}, {})
      expect(gatherer.instance_variable_get(:@current_period_data)).to receive(:group)
      gatherer.group
    end
  end

end
