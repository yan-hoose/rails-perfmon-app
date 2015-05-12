require "rails_helper"

RSpec.describe RequestsController, :type => :controller do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @website = FactoryGirl.create(:website)
    FactoryGirl.create(:users_website, user: @user, website: @website)
  end

  describe 'POST #create' do
    let(:reqs) { [] << FactoryGirl.build(:request) }

    it 'responds with an empty template' do
      post :create, api_key: @website.api_key, requests: reqs.to_json
      expect(response).to render_template(nil)
    end

    it 'responds with unauthorized in case of a wrong API key' do
      post :create, api_key: 'nope', requests: reqs.to_json
      expect(response).to have_http_status(401)
    end

    it 'sets request view_runtime as 0 when view runtime is missing' do
      reqs = [] << FactoryGirl.attributes_for(:request).except(:view_runtime)
      expect {
        post :create, api_key: @website.api_key, requests: reqs.to_json
      }.to change(Request, :count).by(1)
      expect(response).to have_http_status(200)
      expect(Request.last.view_runtime).to eq(0)
    end

    it 'sets request format as html when format is missing' do
      reqs = [] << FactoryGirl.attributes_for(:request).merge(format: nil)
      expect {
        post :create, api_key: @website.api_key, requests: reqs.to_json
      }.to change(Request, :count).by(1)
      expect(response).to have_http_status(200)
      expect(Request.last.format).to eq('html')
    end

    context 'invalid data' do
      after(:each) do
        expect(response).to have_http_status(400)
      end

      it 'responds with a bad_request code in case of an invalid json' do
        post :create, api_key: @website.api_key, requests: 'totally not valid here'
      end

      it 'keeps trying to insert data after invalid request data is encountered (missing controller)' do
        reqs << FactoryGirl.build(:request, controller: nil) << FactoryGirl.build(:request)
        expect {
          post :create, api_key: @website.api_key, requests: reqs.to_json
        }.to change(Request, :count).by(2)
        expect(@website.requests.all?{ |e| e.controller.present? }).to be true
      end

      it 'keeps trying to insert data after invalid request data is encountered (invalid time)' do
        reqs << FactoryGirl.build(:request, time: 'string, not time') << FactoryGirl.build(:request)
        expect {
          post :create, api_key: @website.api_key, requests: reqs.to_json
        }.to change(Request, :count).by(2)
      end

      it 'ingores random json' do
        reqs = [] << '{"random_attribute": "random", "this is not a valid request": 100}'
        expect {
          post :create, api_key: @website.api_key, requests: reqs.to_json
        }.to change(Request, :count).by(0)
      end
    end

    context 'valid request data' do
      it 'successfully saves all requests and returns 200 OK' do
        reqs << FactoryGirl.build(:request) << FactoryGirl.build(:request)
        expect {
          post :create, api_key: @website.api_key, requests: reqs.to_json
        }.to change(Request, :count).by(3)
        expect(response).to have_http_status(200)
      end
    end

  end

end