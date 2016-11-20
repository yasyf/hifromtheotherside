class Pairing < ApplicationRecord
  belongs_to :user_1, class_name: "User"
  belongs_to :user_2, class_name: "User"

  validates :user_2, uniqueness: { scope: :user_1 }

  def self.pair!(user_1, user_2)
    return unless user_1 != user_2
    user_1_id = [user_1.id, user_2.id].min
    user_2_id = [user_1.id, user_2.id].max
    pairing = create! user_1_id: user_1_id, user_2_id: user_2_id
    user_1.update! paired: true
    user_2.update! paired: true
    pairing
  end
end
