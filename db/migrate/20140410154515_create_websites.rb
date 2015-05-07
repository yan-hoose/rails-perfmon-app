class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :name, null: false
      t.string :url
      t.string :api_key, null: false
      t.timestamps
    end
    add_index :websites, :api_key, unique: true
  end
end
