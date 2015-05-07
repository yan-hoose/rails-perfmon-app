class Website < ActiveRecord::Base
  has_many :users_websites, dependent: :delete_all
  has_many :users, through: :users_websites
  has_many :requests, dependent: :delete_all
  has_many :notes, -> { order(time: :desc) }, dependent: :delete_all
  validates :name, presence: true

  before_validation :generate_new_api_key, on: :create
    
  def generate_new_api_key
    self.api_key = Digest::SHA1.hexdigest(name.to_s + url.to_s + Time.now.to_s + rand(rand(Time.now.to_i)).to_s)
  end

end
