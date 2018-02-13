class InstancesOrganiser < ApplicationRecord
  belongs_to :instance
  belongs_to :organiser, class_name: 'User', foreign_key: 'organiser_id'
  validates_presence_of :instance_id, :organiser_id

  
end
