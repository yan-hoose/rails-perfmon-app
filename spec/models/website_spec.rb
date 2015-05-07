require "rails_helper"

RSpec.describe Website, :type => :model do
  let!(:website) { FactoryGirl.create(:website) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(website).to be_valid
    end

    it 'requires a name' do
      website.name = nil
      expect(website).to_not be_valid
    end
  end

  describe 'create' do
    it 'generates a new API key' do
      website = FactoryGirl.create(:website, name: 'New Website!', api_key: nil)

      expect(website.api_key).to_not be_nil
      expect(website.api_key.length).to eq(40) # SHA1 length
    end
  end

  describe 'update' do
    it 'does NOT generate a new API key' do
      api_key = website.api_key

      website.update(name: 'A new name')

      expect(website.api_key).to eq(api_key)
    end
  end

  describe 'destroy' do
    it 'deletes all objects that depend on it' do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:users_website, user: user, website: website)
      FactoryGirl.create(:request, website: website)
      FactoryGirl.create(:note, website: website)

      website.destroy
      expect(Website.count).to eq(0)
      expect(UsersWebsite.count).to eq(0)
      expect(Request.count).to eq(0)
      expect(Note.count).to eq(0)
    end
  end

  describe '#generate_new_api_key' do
    it 'generates a new API key' do
      old_key = website.api_key
      website.generate_new_api_key

      expect(website.api_key).to_not eq(old_key)
    end
  end

end