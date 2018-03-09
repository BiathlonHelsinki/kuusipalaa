class Answer < ApplicationRecord
  belongs_to :question
  translates :body, :contributor_type, :contributor_id
  accepts_nested_attributes_for :translations, reject_if: proc {|x| x['body'].blank? }
  has_many :comments, as: :item
  validates_presence_of :question_id
  after_create :update_activity_feed
  belongs_to :user, optional: true # store user as well as contributor, to attribute authorship later
  
  def update_activity_feed
    Activity.create(user: user,contributor: contributor, item: self, description: "answered_the_question",  addition: 0)
  end


  def read_translated_attribute(name, locale)
    globalize.stash.contains?(locale, name) ? globalize.stash.read(locale, name) : translation_for(locale).send(name)
  end

  def contributor
    contributor_type.nil? ? nil : contributor_type.constantize.find(contributor_id)
  end

  def root_comment
    self.question.page
  end

  def notifications
    []
  end
end

class Answer::Translation
   belongs_to :contributor, polymorphic: true
   validates_presence_of :contributor_id, :contributor_type
end