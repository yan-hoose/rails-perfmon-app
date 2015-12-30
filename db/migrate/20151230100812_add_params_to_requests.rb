class AddParamsToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :params, :json, null: true
  end
end
