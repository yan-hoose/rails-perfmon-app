require "rails_helper"

RSpec.describe ReportsController, :type => :controller do
  login_user
  before(:each) do
    @website = FactoryGirl.create(:website)
    FactoryGirl.create(:users_website, user: @user, website: @website)
  end

  context 'report data collection' do
    before(:each) do
      FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'index',
        method: 'GET', status: 200, db_runtime: 150, view_runtime: 70, total_runtime: 400)
      FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'index',
        method: 'GET', status: 304, db_runtime: 100, view_runtime: 90, total_runtime: 250)
      FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'index',
        method: 'GET', status: 200, db_runtime: 90, view_runtime: 190, total_runtime: 370)
      FactoryGirl.create(:request, website: @website, controller: 'PostsController', action: 'create',
        method: 'POST', status: 200, db_runtime: 600, view_runtime: 120, total_runtime: 1050)
      FactoryGirl.create(:request, website: @website, controller: 'CommentsController', action: 'index',
        method: 'GET', status: 200, db_runtime: 120, view_runtime: 140, total_runtime: 380)
      FactoryGirl.create(:request, website: @website, controller: 'CommentsController', action: 'index',
        method: 'GET', status: 200, db_runtime: 110, view_runtime: 110, total_runtime: 280)

      expect(controller).to receive(:set_website).and_call_original
    end

    after(:each) do
      expect(response).to be_success
      expect(assigns(:website)).to eq(@website)
    end

    it 'gathers data for GET #overview' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :overview, params: {website_id: @website.id}

      result_data = assigns(:result_data)
      expect(result_data).to_not be_nil
      expect(result_data.tabular_data.length).to eq(3)

      row = result_data.tabular_data[0]
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(3)

      row = result_data.tabular_data[1]
      expect(row.controller).to eq('CommentsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(2)

      row = result_data.tabular_data[2]
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('create')
      expect(row.hits).to eq(1)

      methods = assigns(:http_methods)
      expect(methods.size).to eq(2)
      expect(methods['GET']).to eq(5)
      expect(methods['POST']).to eq(1)

      statuses = assigns(:http_statuses)
      expect(statuses.size).to eq(2)
      expect(statuses[200]).to eq(5)
      expect(statuses[304]).to eq(1)
    end

    it 'gathers data for GET #request_durations' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :request_durations, params: {website_id: @website.id}

      result_data = assigns(:result_data)
      expect(result_data).to_not be_nil
      expect(result_data.tabular_data.length).to eq(3)
      sort_result_data(result_data)

      row = result_data.tabular_data.find { |row| row.controller == 'PostsController' && row.action == 'create' }
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('create')
      expect(row.hits).to eq(1)
      expect(row.sum).to eq(1050)
      expect(row.avg).to eq(1050)
      expect(row.min).to eq(1050)
      expect(row.max).to eq(1050)

      row = result_data.tabular_data.find { |row| row.controller == 'PostsController' && row.action == 'index' }
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(3)
      expect(row.sum).to eq(1020)
      expect(row.avg).to eq(340)
      expect(row.min).to eq(250)
      expect(row.max).to eq(400)

      row = result_data.tabular_data.find { |row| row.controller == 'CommentsController' && row.action == 'index' }
      expect(row.controller).to eq('CommentsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(2)
      expect(row.sum).to eq(660)
      expect(row.avg).to eq(330)
      expect(row.min).to eq(280)
      expect(row.max).to eq(380)
    end

    it 'gathers data for GET #db_time' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :db_time, params: {website_id: @website.id}

      result_data = assigns(:result_data)
      expect(result_data).to_not be_nil
      expect(result_data.tabular_data.length).to eq(3)
      sort_result_data(result_data)

      row = result_data.tabular_data.find { |row| row.controller == 'PostsController' && row.action == 'create' }
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('create')
      expect(row.hits).to eq(1)
      expect(row.sum).to eq(600)
      expect(row.avg).to eq(600)
      expect(row.min).to eq(600)
      expect(row.max).to eq(600)

      row = result_data.tabular_data.find { |row| row.controller == 'PostsController' && row.action == 'index' }
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(3)
      expect(row.sum).to eq(340)
      expect(row.avg.round).to eq(113)
      expect(row.min).to eq(90)
      expect(row.max).to eq(150)

      row = result_data.tabular_data.find { |row| row.controller == 'CommentsController' && row.action == 'index' }
      expect(row.controller).to eq('CommentsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(2)
      expect(row.sum).to eq(230)
      expect(row.avg).to eq(115)
      expect(row.min).to eq(110)
      expect(row.max).to eq(120)
    end

    it 'gathers data for GET #view_time' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :view_time, params: {website_id: @website.id}

      result_data = assigns(:result_data)
      expect(result_data).to_not be_nil
      expect(result_data.tabular_data.length).to eq(3)
      sort_result_data(result_data)

      row = result_data.tabular_data.find { |row| row.controller == 'PostsController' && row.action == 'index' }
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(3)
      expect(row.sum).to eq(350)
      expect(row.avg.round).to eq(117)
      expect(row.min).to eq(70)
      expect(row.max).to eq(190)

      row = result_data.tabular_data.find { |row| row.controller == 'CommentsController' && row.action == 'index' }
      expect(row.controller).to eq('CommentsController')
      expect(row.action).to eq('index')
      expect(row.hits).to eq(2)
      expect(row.sum).to eq(250)
      expect(row.avg).to eq(125)
      expect(row.min).to eq(110)
      expect(row.max).to eq(140)

      row = result_data.tabular_data.find { |row| row.controller == 'PostsController' && row.action == 'create' }
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('create')
      expect(row.hits).to eq(1)
      expect(row.sum).to eq(120)
      expect(row.avg).to eq(120)
      expect(row.min).to eq(120)
      expect(row.max).to eq(120)
    end

    it 'gathers data for GET #blockers' do
      @website.requests << FactoryGirl.create(:request, controller: 'PostsController', action: 'index', total_runtime: 1200)
      @website.requests << FactoryGirl.create(:request, controller: 'PostsController', action: 'index', total_runtime: 1000)
      @website.requests << FactoryGirl.create(:request, controller: 'PostsController', action: 'index', total_runtime: 999)

      expect(controller).to receive(:set_blocker_result_data).once.and_call_original

      get :blockers, params: {website_id: @website.id}
      expect(assigns(:overall_blocker_count)).to eq(3)

      result_data = assigns(:result_data)
      expect(result_data).to_not be_nil
      expect(result_data.tabular_data.length).to eq(2)

      row = result_data.tabular_data[0]
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('index')
      expect(row.count).to eq(2)

      row = result_data.tabular_data[1]
      expect(row.controller).to eq('PostsController')
      expect(row.action).to eq('create')
      expect(row.count).to eq(1)
    end

    it 'gets #nr_of_requests_chart json' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :nr_of_requests_chart, params: {website_id: @website.id}, format: :json

      data = JSON.parse(response.body)
      data['data'].each do |req|
        expect(req.has_key?('hits')).to be(true)
      end
    end

    it 'gets #avg_request_duration_chart json' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :avg_request_duration_chart, params: {website_id: @website.id}, format: :json

      data = JSON.parse(response.body)
      data['data'].each do |req|
        expect(req.has_key?('avg_db_runtime')).to be(true)
        expect(req.has_key?('avg_view_runtime')).to be(true)
        expect(req.has_key?('avg_other_runtime')).to be(true)
        expect(req.has_key?('avg_total_runtime')).to be(true)
      end
    end

    it 'gets #db_time_chart json' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :db_time_chart, params: {website_id: @website.id}, format: :json

      data = JSON.parse(response.body)
      data['data'].each do |req|
        expect(req.has_key?('avg_db_runtime')).to be(true)
      end
    end

    it 'gets #view_time_chart json' do
      expect(controller).to receive(:set_result_data).once.and_call_original

      get :view_time_chart, params: {website_id: @website.id}, format: :json

      data = JSON.parse(response.body)
      data['data'].each do |req|
        expect(req.has_key?('avg_view_runtime')).to be(true)
      end
    end

    it 'gets #blocker_count_chart json' do
      expect(controller).to receive(:set_blocker_result_data).once.and_call_original

      get :blocker_count_chart, params: {website_id: @website.id}, format: :json

      data = JSON.parse(response.body)
      data['data'].each do |req|
        expect(req.has_key?('count')).to be(true)
      end
    end

    context 'with comparison data' do
      before(:each) do
        @website.requests << FactoryGirl.create(:request, controller: 'PostsController', action: 'index',
          method: 'GET', status: 200, db_runtime: 10, view_runtime: 7, total_runtime: 25, time: Time.now - 5.days)
        @website.requests << FactoryGirl.create(:request, controller: 'PostsController', action: 'index',
          method: 'GET', status: 304, db_runtime: 10, view_runtime: 7, total_runtime: 25, time: Time.now - 5.days)
        @website.requests << FactoryGirl.create(:request, controller: 'PostsController', action: 'create',
          method: 'POST', status: 200, db_runtime: 10, view_runtime: 7, total_runtime: 1000, time: Time.now - 5.days)
      end
      let(:params_hash) { {params: {
        website_id: @website.id,
        start: Date.today - 1.day,
        end: Date.today,
        compare_periods: true,
        comparison_start: Date.today - 6.days,
        comparison_end: Date.today - 4.days
      }} }

      it 'gathers data for GET #overview' do
        get :overview, params_hash

        result_data = assigns(:result_data)
        expect(result_data).to_not be_nil
        expect(result_data.tabular_data).to_not be_nil
        expect(result_data.comparison_data_hash).to_not be_nil
      end

      it 'gathers data for GET #request_durations' do
        get :request_durations, params_hash

        result_data = assigns(:result_data)
        expect(result_data).to_not be_nil
        expect(result_data.tabular_data).to_not be_nil
        expect(result_data.comparison_data_hash).to_not be_nil
      end

      it 'gathers data for GET #db_time' do
        get :db_time, params_hash

        result_data = assigns(:result_data)
        expect(result_data).to_not be_nil
        expect(result_data.tabular_data).to_not be_nil
        expect(result_data.comparison_data_hash).to_not be_nil
      end

      it 'gathers data for GET #view_time' do
        get :view_time, params_hash

        result_data = assigns(:result_data)
        expect(result_data).to_not be_nil
        expect(result_data.tabular_data).to_not be_nil
        expect(result_data.comparison_data_hash).to_not be_nil
      end

      it 'gathers data for GET #blockers' do
        get :blockers, params_hash

        result_data = assigns(:result_data)
        expect(result_data).to_not be_nil
        expect(result_data.tabular_data).to_not be_nil
        expect(result_data.comparison_data_hash).to_not be_nil
      end

      it 'gets #nr_of_requests_chart json' do
        get :nr_of_requests_chart, params_hash.merge(format: :json)

        data = JSON.parse(response.body)
        expect(data['comparison_data'].size > 0).to be(true)
        data['comparison_data'].each do |req|
          expect(req.has_key?('hits')).to be(true)
        end
      end

      it 'gets #avg_request_duration_chart json' do
        get :avg_request_duration_chart, params_hash.merge(format: :json)

        data = JSON.parse(response.body)
        expect(data['comparison_data'].size > 0).to be(true)
        data['comparison_data'].each do |req|
          expect(req.has_key?('avg_db_runtime')).to be(false)
          expect(req.has_key?('avg_view_runtime')).to be(false)
          expect(req.has_key?('avg_other_runtime')).to be(false)
          expect(req.has_key?('avg_total_runtime')).to be(true)
        end
      end

      it 'gets #db_time_chart json' do
        get :db_time_chart, params_hash.merge(format: :json)

        data = JSON.parse(response.body)
        expect(data['comparison_data'].size > 0).to be(true)
        data['comparison_data'].each do |req|
          expect(req.has_key?('avg_db_runtime')).to be(true)
        end
      end

      it 'gets #view_time_chart json' do
        get :view_time_chart, params_hash.merge(format: :json)

        data = JSON.parse(response.body)
        expect(data['comparison_data'].size > 0).to be(true)
        data['comparison_data'].each do |req|
          expect(req.has_key?('avg_view_runtime')).to be(true)
        end
      end

      it 'gets #blocker_count_chart json' do
        get :blocker_count_chart, params_hash.merge(format: :json)

        data = JSON.parse(response.body)
        expect(data['comparison_data'].size > 0).to be(true)
        data['comparison_data'].each do |req|
          expect(req.has_key?('count')).to be(true)
        end
      end
    end
  end

  describe '#set_website' do
    it 'scopes the query to current users websites' do
      expect_any_instance_of(ReportsController).to receive(:set_website).twice.and_call_original

      get :overview, params: {website_id: @website.id}
      expect(assigns(:website)).to eq(@website)

      other_user = FactoryGirl.create(:user)
      other_website = FactoryGirl.create(:website)
      FactoryGirl.create(:users_website, website: other_website, user: other_user)

      expect {
        get :overview, params: {website_id: other_website.id}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#set_blocker_result_data' do
    it 'includes additional filtering conditions' do
      controller.instance_variable_set(:@website, @website)
      controller.send(:set_blocker_result_data)
      expect(controller.instance_variable_get(:@result_data).
        instance_variable_get(:@current_period_data).instance_variable_get(:@additional_filtering_conditions)).
        to eq('total_runtime >= 1000')
    end
  end

  describe '#dashboard' do
    it 'uses application layout' do
      get :dashboard

      expect(response).to render_template(layout: 'application')
    end

    it 'does not set website with before_action' do
      expect(controller).to_not receive(:set_website)

      get :dashboard
    end

    it 'creates a report data gatherer object for every website of current_user' do
      second_website = FactoryGirl.create(:website)
      third_website = FactoryGirl.create(:website)
      FactoryGirl.create(:users_website, user: @user, website: second_website)
      FactoryGirl.create(:users_website, user: @user, website: third_website)

      somebody_else = FactoryGirl.create(:user)
      somebody_elses_website = FactoryGirl.create(:website)
      FactoryGirl.create(:users_website, user: somebody_else, website: somebody_elses_website)

      expect(ReportsDataGatherer).to receive(:new).exactly(3).times.and_call_original

      get :dashboard

      reports = assigns(:reports)
      expect(reports.length).to eq(3)
      reports.each_pair do |key, value|
        expect(@user.website_ids.include?(key)).to be(true)
        expect(value.class).to be(ReportsDataGatherer)
      end
    end

    it 'creates the report data gatherer objects with specific filters' do
      expect(ReportsDataGatherer).to receive(:new).with(@website, {
        dashboard: 'true',
        start_date: Date.today - 2.days,
        end_date: Date.today,
        compare_periods: false,
        contr: '',
        act: ''
      }, session).once

      get :dashboard
    end
  end

end
