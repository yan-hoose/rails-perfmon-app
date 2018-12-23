class UsersWebsite < ApplicationRecord
  belongs_to :user, optional: false
  belongs_to :website, optional: false

end
