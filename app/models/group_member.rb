class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :question

  validates :group, presence: true
  validates :question, presence: true, uniqueness: { scope: [:group] }
end
