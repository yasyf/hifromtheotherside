class Pairing < ApplicationRecord
  belongs_to :user_1, class_name: "User"
  belongs_to :user_2, class_name: "User"

  validates :user_2, uniqueness: { scope: :user_1 }

  def self.pair!(user_1, user_2)
    user_1_id = [user_1.id, user_2.id].min
    user_2_id = [user_1.id, user_2.id].max

    user_1.paired!
    user_2.paired!

    create! user_1: user_1_id, user_2: user_2_id
  end
end
