class Question < ApplicationRecord
  belongs_to :page
  belongs_to :era
  translates :question
  has_many :answers
  belongs_to :user, optional: true
  belongs_to :contributor, polymorphic:true, optional: true
  extend FriendlyId
  friendly_id :title_en , :use => [ :slugged, :finders, :history]
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['question'].blank?  }
  accepts_nested_attributes_for :answers, reject_if: :has_translation? 
  validates :user_id, presence: true, on: :create

  after_create :update_activity_feed

  def update_activity_feed
    Activity.create(user: user, contributor: contributor, item: self, description: "asked_the_question",  addition: 0, extra: page)
  end

  def read_translated_attribute(name, locale)
    globalize.stash.contains?(locale, name) ? globalize.stash.read(locale, name) : translation_for(locale).send(name)
  end

  private

  def has_translation?(att)
    att["translations_attributes"].map{|x| x.last['body'].blank? }.uniq == [true]
    
  end
  def title_en
    self.question(:en)  
  end

  # def answer_attributes=(attributes)
  #   if attributes['id'].present?
  #     self.answer = Answer.find(attributes['id'])
  #   end
  #   super
  # end
end
