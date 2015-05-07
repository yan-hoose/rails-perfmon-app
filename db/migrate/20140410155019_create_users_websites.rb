class CreateUsersWebsites < ActiveRecord::Migration
  def up
    create_table :users_websites do |t|
      t.references :user, null: false
      t.references :website, null: false
    end
    execute 'ALTER TABLE users_websites ADD CONSTRAINT users_websites_website_id_fkey FOREIGN KEY (website_id) REFERENCES websites (id)'
    execute 'ALTER TABLE users_websites ADD CONSTRAINT users_websites_user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)'
    add_index :users_websites, :website_id
    add_index :users_websites, :user_id
  end

  def down
    drop_table :users_websites
  end
end
