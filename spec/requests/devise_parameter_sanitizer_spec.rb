require 'rails_helper'

RSpec.describe 'devise parameter sanitizer', :type => :request do

  it 'permits :time_zone parameter for :account_update' do
    user = FactoryGirl.create(:user, password: '123123123', password_confirmation: '123123123')
    post_via_redirect user_session_path, user: {email: user.email, password: '123123123'}

    patch user_registration_path, user: {email: user.email, time_zone: 'Bangkok', current_password: '123123123'}

    user.reload
    expect(user.time_zone).to eq('Bangkok')
  end

end