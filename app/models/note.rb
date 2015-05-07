class Note < ActiveRecord::Base
  belongs_to :website
  validates :website_id, :time, :text, presence: true

end
