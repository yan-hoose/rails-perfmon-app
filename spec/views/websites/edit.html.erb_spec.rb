require 'rails_helper'

RSpec.describe 'websites/edit', :type => :view do
  let!(:website) { FactoryGirl.create(:website) }
  before(:each) do
    assign(:website, website)
    render
  end

  it 'renders the _form partial' do
    expect(view).to render_template(partial: '_form', count: 1)
  end

  it 'displays the API key' do
    assert_select "input[id='api_key'][value='#{website.api_key}']", count: 1
  end
end