class GiftCard < ApplicationRecord
  validates :store, :url, :challenge, :amount, presence: true
  validates :number, presence: true, uniqueness: true

  belongs_to :pairing


end
