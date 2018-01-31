class Idea < ApplicationRecord
  belongs_to :proposer, polymorphic: true
  belongs_to :parent, polymorphic: true
  belongs_to :proposalstatus
  belongs_to :ideatype
end
