class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :website, null: false
      t.text :text, null: false
      t.datetime :time, null: false
    end
    add_index :notes, :website_id
    add_foreign_key :notes, :websites, name: 'notes_website_id_fkey'

    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE notes ALTER COLUMN time TYPE TIMESTAMP WITH TIME ZONE'
      end
      dir.down do
        # no need to do anything here
      end
    end
  end
end
