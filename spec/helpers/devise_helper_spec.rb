require 'rails_helper'

# make resource available for us to override it
DeviseHelper.class_eval do
  def resource
  end
end

RSpec.describe DeviseHelper, :type => :helper do

  describe '#devise_error_messages!' do
    it 'returns error list when resource invalid' do
      note = FactoryGirl.build(:note)
      note.text = note.time = nil # let's make it invalid
      note.valid? # trigger validations
      allow(helper).to receive(:resource).and_return(note)

      expect(helper.devise_error_messages!).to eq("    <div id=\"error_explanation\">\n      <h3>2 errors prohibited this note from being saved:</h3>\n      <ul><li>Time can&#39;t be blank</li><li>Text can&#39;t be blank</li></ul>\n    </div>\n")
    end

    it 'returns empty string when resource has no errors' do
      note = FactoryGirl.build(:note)
      note.valid? # trigger validations
      allow(helper).to receive(:resource).and_return(note)
      
      expect(helper.devise_error_messages!).to eq('')
    end
  end

end