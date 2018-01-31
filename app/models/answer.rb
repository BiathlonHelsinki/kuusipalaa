class Answer < ApplicationRecord
  belongs_to :question
  translates :body
  accepts_nested_attributes_for :translations, reject_if: proc {|x| x['body'].blank? }

  def no_translation?
    die
    
  end
end
