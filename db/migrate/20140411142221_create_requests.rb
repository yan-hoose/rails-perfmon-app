class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :website, null: false
      t.string :controller, null: false
      t.string :action, null: false
      t.string :method, null: false
      t.string :format, null: false
      t.integer :status, null: false, limit: 2 # smallint
      t.float :view_runtime, null: false, limit: 4 # real
      t.float :db_runtime, null: false, limit: 4 # real
      t.float :total_runtime, null: false, limit: 4 # real
      t.datetime :time, null: false
    end
    add_index :requests, :website_id
  end
end
