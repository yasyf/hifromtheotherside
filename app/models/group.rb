class Group < ApplicationRecord
  has_many :group_members
  has_many :questions, -> { distinct }, through: :group_members
  has_many :user_groups
  has_many :users, -> { distinct }, through: :user_groups

  validates :level, presence: true
  validates :name, presence: true

  enum level: [:city, :postal, :region, :country]

  def self.keys(level)
    where(level: level).pluck(:name, :id)
  end
end
