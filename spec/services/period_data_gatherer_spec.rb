require "rails_helper"

RSpec.describe PeriodDataGatherer do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @website = FactoryGirl.create(:website)
    FactoryGirl.create(:users_website, user: @user, website: @website)

    @r1 = FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'index', time: Time.gm(2015, 4, 1, 16, 59))
    @r2 = FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'index', time: Time.gm(2015, 4, 1, 17, 00))
    @r3 = FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'update', time: Time.gm(2015, 4, 1, 18, 00))
    @r4 = FactoryGirl.create(:request, website: @website, controller: 'CommentsController', action: 'create', time: Time.gm(2015, 4, 2, 10, 00))
    @r5 = FactoryGirl.create(:request, website: @website, controller: 'CommentsController', action: 'create', time: Time.gm(2015, 4, 3, 16, 59))
    @r6 = FactoryGirl.create(:request, website: @website, controller: 'CommentsController', action: 'update', time: Time.gm(2015, 4, 3, 17, 00))
  end
  let(:default_filters) { ReportsDataGatherer.new(@website, {}, {}).filters }

  describe '#initialize' do
    it 'sets instance variables' do
      gatherer = PeriodDataGatherer.new(@website, default_filters, 'additional conditions')
      expect(gatherer.instance_variable_get(:@website)).to be(@website)
      expect(gatherer.instance_variable_get(:@filters)).to be(default_filters)
      expect(gatherer.instance_variable_get(:@additional_filtering_conditions)).to eq('additional conditions')
    end

    it 'creates filtered rows query' do
      expect_any_instance_of(PeriodDataGatherer).to receive(:get_filtered_rows)
      gatherer = PeriodDataGatherer.new(@website, {})
    end
  end

  describe '#generate_tabular_data' do
    it 'creates @tabular_data by running the block on @filtered_rows and applying sort order' do
      gatherer = PeriodDataGatherer.new(@website, default_filters)
      
      expect(gatherer.instance_variable_get(:@filtered_rows)).to receive(:instance_eval).and_call_original
      expect(gatherer.instance_variable_get(:@filtered_rows)).to receive(:order).with('max ASC').and_call_original
      gatherer.generate_tabular_data('max ASC') do
        select('controller, action, MAX(total_runtime) AS max').group('controller, action')
      end
      expect(gatherer.tabular_data).to_not be_nil
    end
  end

  describe 'delegate' do
    it 'delegates the :group method to @filtered_rows' do
      gatherer = PeriodDataGatherer.new(@website, default_filters)
      expect(gatherer.instance_variable_get(:@filtered_rows)).to receive(:group).with(:method)
      gatherer.group(:method)
    end
  end

  describe '#get_filtered_rows' do
    it 'gets filtered rows in current time zone (Bangkok)' do
      Time.zone = 'Bangkok' # UTC +07:00
      params = {
        start_date: '2015-04-02',
        end_date: '2015-04-03'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      requests = gatherer.send(:get_filtered_rows)
      expect(requests.length).to eq(4)
      expect(requests).to match_array([@r2, @r3, @r4, @r5])
    end

    it 'gets filtered rows in current time zone (UTC)' do
      Time.zone = 'UTC'
      params = {
        start_date: '2015-04-02',
        end_date: '2015-04-03'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      requests = gatherer.send(:get_filtered_rows)
      expect(requests.length).to eq(3)
      expect(requests).to match_array([@r4, @r5, @r6])
    end

    it 'filters by controller' do
      params = {
        start_date: '2015-04-01',
        end_date: '2015-04-02',
        contr: 'PostsController'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      requests = gatherer.send(:get_filtered_rows)
      expect(requests.length).to eq(3)
      expect(requests).to match_array([@r1, @r2, @r3])
    end

    it 'filters by action' do
      params = {
        start_date: '2015-04-01',
        end_date: '2015-04-03',
        act: 'update'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      requests = gatherer.send(:get_filtered_rows)
      expect(requests.length).to eq(2)
      expect(requests).to match_array([@r3, @r6])
    end

    it 'filters by all combined' do
      params = {
        start_date: '2015-04-02',
        end_date: '2015-04-02',
        controller: 'CommentsController',
        action: 'create'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      requests = gatherer.send(:get_filtered_rows)
      expect(requests.length).to eq(1)
      expect(requests).to match_array([@r4])
    end

    it 'gets filtered rows of only the selected website' do
      another_website = FactoryGirl.create(:website)
      FactoryGirl.create(:users_website, user: @user, website: another_website)
      FactoryGirl.create(:request, website: another_website, time: Time.gm(2015, 4, 1, 18, 00))
      FactoryGirl.create(:request, website: another_website, time: Time.gm(2015, 4, 2, 10, 00))
      FactoryGirl.create(:request, website: another_website, time: Time.gm(2015, 4, 3, 16, 59))
      FactoryGirl.create(:request, website: another_website, time: Time.gm(2015, 4, 3, 17, 00))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 1, 18, 00))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 2, 10, 00))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 3, 16, 59))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 3, 17, 00))
      params = {
        start_date: '2015-04-01',
        end_date: '2015-04-04'
      }
      gatherer = PeriodDataGatherer.new(another_website, default_filters.merge(params))

      expect(another_website).to receive(:requests).once.and_call_original

      requests = gatherer.send(:get_filtered_rows)

      expect(requests.length).to eq(4)
      expect(requests.all? {|r| r.website_id == another_website.id}).to be(true)
    end

    it 'adds an additional where condition if @additional_filtering_conditions is set' do
      params = {
        start_date: '2015-04-02',
        end_date: '2015-04-03'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params), 'a_fake_column >= a_fake_value')
      requests = gatherer.send(:get_filtered_rows)
      expect(requests.to_sql).to include('AND (a_fake_column >= a_fake_value)')
    end
  end

  describe '#chart_data' do
    before(:each) do
      # 2015-04-15 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 16, 39), db_runtime: 11)
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 16, 59), db_runtime: 15)
      # 2015-04-16 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 18, 20), db_runtime: 17) # 01:20 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 18, 32), db_runtime: 18) # 01:32 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 21, 59), db_runtime: 22) # 04:59 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 21, 59), db_runtime: 12) # 04:59 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 22, 11), db_runtime: 35) # 05:11 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 22, 12), db_runtime: 43) # 05:12 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 15, 22, 30), db_runtime: 21) # 05:30 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 16, 0, 30), db_runtime: 14) # 07:30 in Bangkok
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 16, 2, 2), db_runtime: 37) # 09:02 in Bangkok
    end

    it 'gets hourly data points in current time zone (Bangkok)' do
      Time.zone = 'Bangkok' # UTC +07:00, unix timestamp offset: 25200
      params = {
        start_date: '2015-04-16',
        end_date: '2015-04-16'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      chart_data = gatherer.send(:chart_data, 'AVG(db_runtime)::int AS avg_db_runtime')

      expect(chart_data.length).to eq(5)
      expect(chart_data[0].avg_db_runtime).to eq(18)
      expect(chart_data[0].timespan.to_i).to eq(1429146000) # 2015-04-16 01:00:00
      expect(chart_data[1].avg_db_runtime).to eq(17)
      expect(chart_data[1].timespan.to_i).to eq(1429156800) # 2015-04-16 04:00:00
      expect(chart_data[2].avg_db_runtime).to eq(33)
      expect(chart_data[2].timespan.to_i).to eq(1429160400) # 2015-04-16 05:00:00
      expect(chart_data[3].avg_db_runtime).to eq(14)
      expect(chart_data[3].timespan.to_i).to eq(1429167600) # 2015-04-16 07:00:00
      expect(chart_data[4].avg_db_runtime).to eq(37)
      expect(chart_data[4].timespan.to_i).to eq(1429174800) # 2015-04-16 09:00:00
    end

    it 'gets hourly data points in current time zone (UTC)' do
      Time.zone = 'UTC'
      params = {
        start_date: '2015-04-15',
        end_date: '2015-04-15'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      chart_data = gatherer.send(:chart_data, 'AVG(db_runtime)::int AS avg_db_runtime')

      expect(chart_data.length).to eq(4)
      expect(chart_data[0].avg_db_runtime).to eq(13)
      expect(chart_data[0].timespan.to_i).to eq(1429113600) # 2015-04-15 16:00:00
      expect(chart_data[1].avg_db_runtime).to eq(18)
      expect(chart_data[1].timespan.to_i).to eq(1429120800) # 2015-04-15 18:00:00
      expect(chart_data[2].avg_db_runtime).to eq(17)
      expect(chart_data[2].timespan.to_i).to eq(1429131600) # 2015-04-15 21:00:00
      expect(chart_data[3].avg_db_runtime).to eq(33)
      expect(chart_data[3].timespan.to_i).to eq(1429135200) # 2015-04-15 22:00:00
    end

    it 'always selects timespan and includes select_fields param' do
      Time.zone = 'UTC'
      params = {
        start_date: '2015-04-15',
        end_date: '2015-04-15'
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      chart_data = gatherer.send(:chart_data, 'AVG(db_runtime)::int AS avg_db_runtime, AVG(view_runtime)::int AS avg_view_runtime')

      chart_data.each do |row|
        expect(row.respond_to?(:timespan)).to be(true)
        expect(row.respond_to?(:avg_db_runtime)).to be(true)
        expect(row.respond_to?(:avg_view_runtime)).to be(true)
      end
    end
  end

  describe '#total_hits' do
    it 'gets total hits' do
      params = {
        start_date: '2015-04-02'.to_date,
        end_date: '2015-04-03'.to_date
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      expect(gatherer.total_hits).to eq(3)
    end
  end

  describe '#requests_per_minute' do
    it 'gets requests per minute' do
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 25))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 25))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 25))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 26))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 26))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 26))
      FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 27))
      params = {
        start_date: '2015-04-25'.to_date,
        end_date: '2015-04-26'.to_date
      }
      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      expect(gatherer.requests_per_minute.round(5)).to eq(0.00208)
    end
  end

  describe '#nth_percentile' do
    it 'gets 95th percentile value' do
      params = {
        start_date: '2015-04-25'.to_date,
        end_date: '2015-04-27'.to_date
      }

      20.times do |i|
        FactoryGirl.create(:request, website: @website, time: Time.gm(2015, 4, 25), total_runtime: i + 1)
      end

      gatherer = PeriodDataGatherer.new(@website, default_filters.merge(params))
      expect(gatherer.nth_percentile).to eq(19)
    end
  end
end