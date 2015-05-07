require "rails_helper"

feature "Log in" do

  scenario "Log in through bootstrap modal popup", js: true do
    user = FactoryGirl.create(:user, password: '123123123')
    visit root_path
    click_link 'Log in'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: '123123123'
    click_button 'Log in'

    expect(page).to have_text('Signed in successfully.')
  end

end