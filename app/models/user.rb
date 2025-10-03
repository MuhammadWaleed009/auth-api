class User < ApplicationRecord
  has_secure_password

  validates :user_id, presence: true, uniqueness: true

  validates :password, length: { minimum: 8, maximum: 20 }, allow_nil: true
  validates :nickname, length: { maximum: 30 }, allow_blank: true
  validates :comment, length: { maximum: 100 }, allow_blank: true
end
