class UsersWebsite < ActiveRecord::Base
  belongs_to :user
  belongs_to :website

end