class UserGroup < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :group, presence: true
  validates :user, presence: true, uniqueness: { scope: [:group] }
end
