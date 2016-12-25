class AddWebsiteIdTimeIndexOnRequests < ActiveRecord::Migration
  # Concurrent index creation can not be done inside a transaction.
  # We'll disable it for this migration.
  disable_ddl_transaction!

  def change
    remove_index :requests, column: :website_id
    add_index :requests, [:website_id, :time], algorithm: :concurrently
  end
end
