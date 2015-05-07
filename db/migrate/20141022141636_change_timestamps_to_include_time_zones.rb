class ChangeTimestampsToIncludeTimeZones < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE requests ALTER COLUMN time TYPE TIMESTAMP WITH TIME ZONE'
    execute 'ALTER TABLE users ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE'
    execute 'ALTER TABLE users ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE'
    execute 'ALTER TABLE websites ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE'
    execute 'ALTER TABLE websites ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE'
  end

  def down
    execute 'ALTER TABLE requests ALTER COLUMN time TYPE TIMESTAMP WITHOUT TIME ZONE'
    execute 'ALTER TABLE users ALTER COLUMN created_at TYPE TIMESTAMP WITHOUT TIME ZONE'
    execute 'ALTER TABLE users ALTER COLUMN updated_at TYPE TIMESTAMP WITHOUT TIME ZONE'
    execute 'ALTER TABLE websites ALTER COLUMN created_at TYPE TIMESTAMP WITHOUT TIME ZONE'
    execute 'ALTER TABLE websites ALTER COLUMN updated_at TYPE TIMESTAMP WITHOUT TIME ZONE'
  end
end
