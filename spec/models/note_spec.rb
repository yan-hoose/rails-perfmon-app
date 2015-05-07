require "rails_helper"

RSpec.describe Note, :type => :model do
  context 'validation' do
    let!(:note) { FactoryGirl.create(:note) }

    it 'is valid with valid attributes' do
      expect(note).to be_valid
    end

    it 'requires a website id' do
      note.website_id = nil
      expect(note).to_not be_valid
    end

    it 'requires time' do
      note.time = nil
      expect(note).to_not be_valid
    end

    it 'requires text' do
      note.text = nil
      expect(note).to_not be_valid
    end
  end
end