class RemoveSelectedDaterangeFromUsersWebsites < ActiveRecord::Migration
  def change
    remove_column :users_websites, :selected_daterange, :string, default: nil
  end
end
