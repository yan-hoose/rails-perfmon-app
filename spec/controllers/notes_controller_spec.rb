require "rails_helper"

RSpec.describe NotesController, :type => :controller do
  login_user
  before(:each) do
    @website = FactoryGirl.create(:website)
    FactoryGirl.create(:users_website, user: @user, website: @website)
  end

  describe 'GET #index' do
    context 'HTML request' do
      it 'responds with HTML' do
        get :index, params: {website_id: @website.id}
        expect(response).to be_successful
        expect(response).to render_template(:index)
      end
    end

    context 'JSON request' do
      it 'responds with JSON' do
        get :index, params: {website_id: @website.id, format: :json, start: Date.today - 1, end: Date.today}
        expect(response).to be_successful
        expect(response).to_not render_template(:index)
        expect { JSON.parse(response.body) }.to_not raise_error
      end

      it 'requires start and end parameters' do
        expect {
          get :index, params: {website_id: @website.id}, format: :json
        }.to raise_error(NoMethodError)

        expect {
          get :index, params: {website_id: @website.id, format: :json, start: Date.today - 1}
        }.to raise_error(NoMethodError)

        expect {
          get :index, params: {website_id: @website.id, format: :json, end: Date.today}
        }.to raise_error(NoMethodError)

        expect {
          get :index, params: {website_id: @website.id, format: :json, start: Date.today - 1, end: Date.today}
        }.to_not raise_error
      end

      it 'requires start and end parameters to be dates' do
        expect {
          get :index, params: {website_id: @website.id, format: :json, start: 'string'}
        }.to raise_error(ArgumentError)

        expect {
          get :index, params: {website_id: @website.id, format: :json, end: 9128419}
        }.to raise_error(NoMethodError)

        expect {
          get :index, params: {website_id: @website.id, format: :json, start: [], end: 'not date'}
        }.to raise_error(NoMethodError)
      end

      context 'time zone differences' do
        before(:each) do
          @note1 = FactoryGirl.create(:note, website: @website, time: Time.gm(2015, 4, 1, 16, 59))
          @note2 = FactoryGirl.create(:note, website: @website, time: Time.gm(2015, 4, 1, 17, 0))
          @note3 = FactoryGirl.create(:note, website: @website, time: Time.gm(2015, 4, 2, 16, 59))
          @note4 = FactoryGirl.create(:note, website: @website, time: Time.gm(2015, 4, 3, 16, 59))
          @note5 = FactoryGirl.create(:note, website: @website, time: Time.gm(2015, 4, 3, 17, 0))
        end

        it 'loads notes based on users time zone when in Bangkok' do
          @user.update_column(:time_zone, 'Bangkok') # UTC +07:00
          get :index, params: {website_id: @website.id, format: :json, start: '2015-04-02', end: '2015-04-03'}
          notes = JSON.parse(response.body)
          expect(notes.length).to eq(3)
          expect(notes[0]['id']).to eq(@note4.id)
          expect(notes[1]['id']).to eq(@note3.id)
          expect(notes[2]['id']).to eq(@note2.id)
        end

        it 'loads notes based on users time zone when in UTC' do
          @user.update_column(:time_zone, 'UTC')
          get :index, params: {website_id: @website.id, format: :json, start: '2015-04-02', end: '2015-04-03'}
          notes = JSON.parse(response.body)
          expect(notes.length).to eq(3)
          expect(notes[0]['id']).to eq(@note5.id)
          expect(notes[1]['id']).to eq(@note4.id)
          expect(notes[2]['id']).to eq(@note3.id)
        end
      end

      it 'loads only website specific notes' do
        my_second_website = FactoryGirl.create(:website)
        FactoryGirl.create(:users_website, user: @user, website: my_second_website)

        note1 = FactoryGirl.create(:note, website: @website, time: Time.gm(2015, 4, 1, 12, 0))
        note2 = FactoryGirl.create(:note, website: my_second_website, time: Time.gm(2015, 4, 1, 12, 0))

        get :index, params: {website_id: @website.id, format: :json, start: '2015-04-01', end: '2015-04-01'}
        notes = JSON.parse(response.body)
        expect(notes.length).to eq(1)
        expect(notes[0]['id']).to eq(note1.id)

        get :index, params: {website_id: my_second_website.id, format: :json, start: '2015-04-01', end: '2015-04-01'}
        notes = JSON.parse(response.body)
        expect(notes.length).to eq(1)
        expect(notes[0]['id']).to eq(note2.id)
      end

      it 'does not load other users website notes' do
        other_user = FactoryGirl.create(:user)
        other_users_website = FactoryGirl.create(:website)
        FactoryGirl.create(:users_website, user: other_user, website: other_users_website)
        FactoryGirl.create(:note, website: other_users_website, time: Time.gm(2015, 4, 1, 12, 0))

        expect {
          get :index, params: {website_id: other_users_website.id, format: :json, start: '2015-04-01', end: '2015-04-01'}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#set_website' do
    it 'loads current users website' do
      other_user = FactoryGirl.create(:user)
      other_users_website = FactoryGirl.create(:website)
      FactoryGirl.create(:users_website, user: other_user, website: other_users_website)

      get :index, params: {website_id: @website.id}
      expect(assigns(:website)).to_not be_nil

      expect {
        get :index, params: {website_id: other_users_website.id}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #new' do
    it 'assings a new note' do
      get :new, params: {website_id: @website.id}
      note = assigns(:note)
      expect(note).to_not be_nil
      expect(note.new_record?).to be true
    end
  end

  describe 'POST #create' do
    it 'creates a new note and renders index' do
      expect {
        post :create, params: {website_id: @website.id, note: FactoryGirl.attributes_for(:note)}
      }.to change { @website.notes.count }.by(1)
      expect(response).to redirect_to(website_notes_path(@website))
      expect(flash[:notice]).to eq('Note added!')
    end

    it 'does not create an invalid note and renders new' do
      expect {
        post :create, params: {website_id: @website.id, note: FactoryGirl.attributes_for(:note, text: '')}
      }.to_not change { @website.notes.count }
      expect(response).to render_template(:new)
    end

    it 'note_params permits all the neccessary fields' do
      expect_any_instance_of(ActiveRecord::Associations::CollectionProxy).to receive(:create).with(ActionController::Parameters.new({
        'text': 'note text',
        'time(1i)': '2015',
        'time(2i)': '4',
        'time(3i)': '6',
        'time(4i)': '15',
        'time(5i)': '09',
      }).permit!).and_call_original

      post :create, params: {website_id: @website.id, note: {
        'text': 'note text',
        "time(1i)" => "2015",
        "time(2i)" => "4",
        "time(3i)" => "6",
        "time(4i)" => "15",
        "time(5i)" => "09"
      }}
    end
  end

  describe 'POST #update' do
    it 'renders index if the update is successful' do
      note = FactoryGirl.create(:note, website: @website)

      allow_any_instance_of(Note).to receive(:update).and_return(true)
      post :update, params: {website_id: @website.id, id: note.id, note: {text: 'bla'}}

      expect(response).to redirect_to(website_notes_path(@website))
      expect(flash[:notice]).to eq('Note updated!')
    end

    it 'renders edit if the update is not successful' do
      note = FactoryGirl.create(:note, website: @website)

      allow_any_instance_of(Note).to receive(:update).and_return(false)
      post :update, params: {website_id: @website.id, id: note.id, note: {text: 'bla'}}

      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the note and redirects' do
      note = FactoryGirl.create(:note, website: @website)

      delete :destroy, params: {website_id: @website.id, id: note.id}

      expect(response).to redirect_to(website_notes_path(@website))
      expect(flash[:notice]).to eq('Note deleted!')
    end
  end

  it 'uses reports layout' do
    get :index, params: {website_id: @website.id}
    expect(response).to render_template(layout: 'reports')
  end

end
