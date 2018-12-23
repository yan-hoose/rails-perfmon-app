class User < ApplicationRecord
  # Include default devise modules. Others available are: :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  has_many :users_websites
  has_many :websites, -> { order(:name) }, through: :users_websites

end
