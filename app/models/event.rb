class Event < ApplicationRecord
  belongs_to :idea, optional: true
  
end