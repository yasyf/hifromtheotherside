class Preference < ApplicationRecord
  validates :name, presence: true
end
