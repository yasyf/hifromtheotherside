class Event < ApplicationRecord
  has_many :users

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :logo, presence: true
end
