class Pledge < ApplicationRecord
  belongs_to :items, polymorphic: true
end