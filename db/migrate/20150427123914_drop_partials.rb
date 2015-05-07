class DropPartials < ActiveRecord::Migration
  def up
    drop_table :partials
  end

  def down
    create_table :partials do |t|
      t.references :website, null: false
      t.string :identifier, null: false
      t.float :render_time, null: false, limit: 4 # real
      t.datetime :time, null: false
    end
    add_index :partials, :website_id
    add_foreign_key :partials, :websites, name: 'partials_website_id_fkey'
  end
end
