require "rails_helper"

RSpec.describe User, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'requires an email' do
      user.email = nil
      expect(user).to_not be_valid
    end

    it 'must have an insensitively unique email' do
      FactoryGirl.create(:user, email: 'an@email.com')

      new_user = FactoryGirl.build(:user, email: 'an@email.com')
      expect(new_user.valid?).to be false

      new_user.email = 'AN@email.com'
      expect(new_user.valid?).to be false

      new_user.email = 'an@Email.COM'
      expect(new_user.valid?).to be false
    end

    it 'must have a valid email' do
      user.email = 'cvbcvb'
      expect(user.valid?).to be false

      user.email = 'cvbcvb@'
      expect(user.valid?).to be false

      user.email = '@cvbcvb'
      expect(user.valid?).to be false
    end
  end

  describe 'associations' do
    it 'orders websites default by name' do
      web1 = FactoryGirl.create(:website, name: 'C website')
      web2 = FactoryGirl.create(:website, name: 'A website')
      web3 = FactoryGirl.create(:website, name: 'B website')
      FactoryGirl.create(:users_website, user: user, website: web1)
      FactoryGirl.create(:users_website, user: user, website: web2)
      FactoryGirl.create(:users_website, user: user, website: web3)

      expect(user.websites.pluck(:name)).to eq(['A website', 'B website', 'C website'])
    end
  end

end