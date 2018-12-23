require "rails_helper"

RSpec.describe WebsitesController, :type => :controller do
  login_user
  before(:each) do
    @website = FactoryGirl.create(:website)
    FactoryGirl.create(:users_website, user: @user, website: @website)
  end

  describe 'GET #new' do
    it 'responds successfully with a new template' do
      get :new
      expect(assigns(:website)).to_not be_nil
      expect(assigns(:website).new_record?).to be(true)
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'creates a new website and redirects' do
      expect {
        post :create, params: {website: FactoryGirl.attributes_for(:website, name: 'A new one')}
      }.to change(@user.websites, :count).by(1)
      expect(response).to redirect_to(overview_website_reports_path(@user.websites.find_by(name: 'A new one')))
      expect(flash[:notice]).to eq('New website created. Nice!')
    end

    it 'uses strong params' do
      expect(controller).to receive(:website_params)
      post :create, params: {website: FactoryGirl.attributes_for(:website)}
    end

    it 'renders new when data is invalid' do
      expect {
        post :create, params: {website: FactoryGirl.attributes_for(:website, name: '')}
      }.to change(@user.websites, :count).by(0)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    it 'responds successfully with an edit template' do
      get :edit, params: {id: @website.id}
      expect(assigns(:website)).to eq(@website)
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #update' do
    it 'updates website and renders edit' do
      post :update, params: {id: @website.id, website: {name: 'Updated name!'}}
      @website.reload
      expect(@website.name).to eq('Updated name!')
      expect(response).to render_template(:edit)
      expect(flash[:notice]).to eq('Website settings changed!')
    end

    it 'uses strong params' do
      expect(controller).to receive(:website_params).and_call_original
      post :update, params: {id: @website.id, website: {name: 'New name!'}}
    end

    it 'renders edit when data is invalid' do
      post :update, params: {id: @website.id, website: {name: ''}}
      @website.reload
      expect(@website.name).to_not eq('')
      expect(response).to render_template(:edit)
      expect(flash[:notice]).to be_nil
    end
  end

  it 'allows only name and url through website_params' do
    expect_any_instance_of(Website).to receive(:update).with(ActionController::Parameters.new({
      'name' => 'New name!',
      'url' => 'www.new.url.com'
    }).permit!).and_call_original
    post :update, params: {id: @website.id, website: {name: 'New name!', url: 'www.new.url.com', api_key: '12345'}}
  end

  describe 'GET #regenerate_api_key' do
    it 'generates a new API key and saves it' do
      expect_any_instance_of(Website).to receive(:generate_new_api_key).once.and_call_original
      expect_any_instance_of(Website).to receive(:save).once.and_call_original
      get :regenerate_api_key, params: {id: @website.id}
      expect(response).to redirect_to(edit_website_path(@website))
      expect(flash[:notice]).to eq('API key successfully regenerated!')
    end
  end

  describe 'GET #confirm_delete' do
    it 'gets confirm_delete' do
      get :confirm_delete, params: {id: @website.id}
      expect(assigns(:website)).to eq(@website)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the website and redirects to dashboard' do
      delete :destroy, params: {id: @website.id}
      expect(Website.count).to eq(0)
      expect(response).to redirect_to dashboard_path
      expect(flash[:notice]).to eq('%s successfully deleted.' % @website.name)
    end
  end

  describe '#set_website' do
    it 'scopes the query to current users websites' do
      expect_any_instance_of(WebsitesController).to receive(:set_website).twice.and_call_original

      get :edit, params: {id: @website.id}
      expect(assigns(:website)).to eq(@website)

      other_user = FactoryGirl.create(:user)
      other_website = FactoryGirl.create(:website)
      FactoryGirl.create(:users_website, website: other_website, user: other_user)

      expect {
        get :edit, params: {id: other_website.id}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
