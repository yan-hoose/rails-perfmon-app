class AddSelectedDaterangeToUsersWebsites < ActiveRecord::Migration
  def change
    add_column :users_websites, :selected_daterange, :string, default: nil
  end
end
