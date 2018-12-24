require "rails_helper"

class TestApplicationController < ApplicationController
  def index
    head :ok
  end
end

RSpec.describe TestApplicationController, :type => :controller do
  before(:each) do
    Rails.application.routes.draw do
      devise_for :users
      get :index, to: 'test_application#index'
    end
  end

  after(:each) do
    Rails.application.reload_routes!
  end

  context 'logged in user' do
    login_user

    it 'checks for authentication' do
      expect(controller).to receive(:authenticate_user!).once.and_call_original
      get :index
      expect(response).to be_successful
    end

    it 'calls set_user_time_zone' do
      expect(controller).to receive(:set_user_time_zone).once
      get :index
      expect(response).to be_successful
    end

    describe '#set_user_time_zone' do
      it 'sets user time zone' do
        @user.update_column(:time_zone, 'Bangkok')
        Time.zone = 'UTC'

        expect {
          get :index
        }.to change {Time.zone.name}.from('UTC').to('Bangkok')
      end

      it 'does not set time zone when it is not present' do
        @user.update_column(:time_zone, '')
        Time.zone = 'UTC'

        expect {
          get :index
        }.to_not change {Time.zone.name}
      end
    end
  end

  context 'not logged in user' do
    it 'redirects to login path' do
      expect(controller).to receive(:authenticate_user!).once.and_call_original
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

end
