class Question < ApplicationRecord
  belongs_to :page
  belongs_to :era
  translates :question
  has_many :answers
  extend FriendlyId
  friendly_id :title_en , :use => [ :slugged, :finders, :history]
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['question'].blank?  }
  accepts_nested_attributes_for :answers, reject_if: :has_translation? 

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
