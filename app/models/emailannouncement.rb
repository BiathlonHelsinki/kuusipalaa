class Emailannouncement < ApplicationRecord
  belongs_to :announcer, polymorphic: true
  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true
  belongs_to :email
end
