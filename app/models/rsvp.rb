class Rsvp < ApplicationRecord
  belongs_to :instance, optional: true
  belongs_to :user
  belongs_to :meeting, optional: true
  validates_presence_of  :user_id
end
