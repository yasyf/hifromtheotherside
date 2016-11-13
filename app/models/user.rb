class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:facebook]

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  CANDIDATES = {
    trump: "Donald Trump",
    clinton: "Hillary Clinton",
    stein: "Jill Stein",
    johnson: "Gary Johnson",
    other: "Other",
  }

  enum supported: CANDIDATES.keys.map { |k| "supported_#{k}" }
  enum desired: CANDIDATES.keys.map { |k| "desired_#{k}" }

  def self.from_omniauth(auth)
    graph = Koala::Facebook::API.new(auth.credentials.token)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      info = graph.get_object("me", fields: 'first_name, last_name, email')
      user.assign_attributes info.except('id')
      user.password = Devise.friendly_token[0,20]
    end
  end
end
