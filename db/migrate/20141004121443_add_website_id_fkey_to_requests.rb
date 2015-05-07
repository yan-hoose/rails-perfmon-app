class AddWebsiteIdFkeyToRequests < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE requests ADD CONSTRAINT requests_website_id_fkey FOREIGN KEY (website_id) REFERENCES websites (id)'
  end

  def down
    execute 'ALTER TABLE requests DROP CONSTRAINT requests_website_id_fkey'
  end
end
