class AlterPartialTimeToIncludeTimezone < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE partials ALTER COLUMN time TYPE TIMESTAMP WITH TIME ZONE'
  end

  def down
    execute 'ALTER TABLE partials ALTER COLUMN time TYPE TIMESTAMP WITHOUT TIME ZONE'
  end
end
