require "rails_helper"

RSpec.describe PublicController, :type => :controller do

  it 'uses public layout' do
    get :index
    expect(response).to render_template(layout: 'public')
  end

  context 'logged in user' do
    login_user

    it 'redirects to dashboard' do
      get :index
      expect(response).to redirect_to(dashboard_path)
    end
  end

  it 'does not redirect if user is not logged in' do
    get :index
    expect(response).to render_template(:index)
  end

end
