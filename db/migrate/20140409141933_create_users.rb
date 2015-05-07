class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :time_zone
      t.timestamps
    end
    execute 'CREATE UNIQUE INDEX users_email_idx ON users((lower(email)))'
  end

  def down
    drop_table :users
  end
end
