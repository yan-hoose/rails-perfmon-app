require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do
  include ERB::Util

  describe '#show_active_record_errors' do
    it 'shows object AR errors if there are any' do
      note = FactoryGirl.build(:note)
      note.text = note.time = nil # let's make it invalid
      note.valid? # trigger validations

      expect(helper.show_active_record_errors(note)).to eq("<div class=\"alert alert-danger\"><h4>Record could not be saved:</h4><ul><li>Time can't be blank</li><li>Text can't be blank</li></ul></div>")
    end

    it 'does not return anything of there are no AR errors on the object' do
      note = FactoryGirl.build(:note)
      note.valid? # trigger validations

      expect(helper.show_active_record_errors(note)).to eq(nil)
    end
  end

  describe '#page_header' do
    it 'shows page heading' do
      expect(helper.page_header('Imagine that, a heading!!')).to eq("<div class=\"page-header\"><h1>Imagine that, a heading!! </h1></div>")
    end

    it 'shows page heading with a subheading' do
      expect(helper.page_header('A heading!!', 'And a sub one!')).to eq("<div class=\"page-header\"><h1>A heading!! <small>And a sub one!</small></h1></div>")
    end
  end

  describe '#show_flash' do
    it 'shows an alert message if flash.alert present' do
      flash[:alert] = 'Oh no, an error!?!!'
      expect(helper.show_flash).to eq("<div class=\"alert alert-danger\">Oh no, an error!?!!</div>")
    end

    it 'shows a notice message if flash.notice present' do
      flash[:notice] = 'Well done!'
      expect(helper.show_flash).to eq("<div class=\"alert alert-info\">Well done!</div>")
    end

    it 'shows an alert messages if both flashes present' do
      flash[:alert] = 'Alert!'
      flash[:notice] = 'Notice!'
      expect(helper.show_flash).to eq("<div class=\"alert alert-danger\">Alert!</div>")
    end
  end

  describe '#duration_in_human' do
    it 'converts milliseconds to human readable form' do
      expect(duration_in_human(1000)).to eq('0m 1s')
      expect(duration_in_human(2400)).to eq('0m 2s')
      expect(duration_in_human(2500)).to eq('0m 3s')
      expect(duration_in_human(60000)).to eq('1m 0s')
      expect(duration_in_human(66000)).to eq('1m 6s')
      expect(duration_in_human(4800000)).to eq('80m 0s')
    end
  end

  describe '#nl2br' do
    it 'converts \n to <br> tags and returns an html_safe string' do
      text = %Q{first line
second line}
      result = nl2br(text)
      expect(result).to eq('first line<br />second line')
      expect(result.html_safe?).to be(true)
    end

    it 'escapes other html tags' do
      text = "text<u>underline</u> and <div>div</div>"
      expect(nl2br(text)).to eq('text&lt;u&gt;underline&lt;/u&gt; and &lt;div&gt;div&lt;/div&gt;')
    end

    it 'returns nil when input is nil' do
      expect(nl2br(nil)).to eq(nil)
    end
  end

end