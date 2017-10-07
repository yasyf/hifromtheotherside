class Question < ApplicationRecord
  belongs_to :preference
  has_many :group_members
  has_many :groups, -> { distinct }, through: :group_members

  validates :preference, presence: true
  validates :yes_label, presence: true
  validates :no_label, presence: true
  validates :text, presence: true

  def self.import
    YAML.load_file(Rails.root.join('config', 'questions.yml'))['questions'].each do |question|
      preference = Preference.where(name: question['preference']).first_or_create!
      q = Question.where(preference: preference, text: question['text']).first_or_initialize.tap do |q|
        q.update_attributes question.slice('yes_label', 'no_label')
        q.save!
      end
      Group.country.where(name: question['country']).first_or_create!.tap do |group|
        q.group_members.where(group: group).first_or_create!
      end if question['country'].present?
    end
  end

  def self.for_user(user)
    eager_load(:groups)
  end
end
