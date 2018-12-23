class Note < ApplicationRecord
  belongs_to :website, optional: false

  validates :website_id, :time, :text, presence: true

end
