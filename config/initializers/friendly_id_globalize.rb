# Hack to override method should_generate_new_friendly_id 
module FriendlyId
  module Globalize

    def should_generate_new_friendly_id?
      regenerated_keys = %w( name title login)
      slug.blank? || (self.changes.keys & regenerated_keys).present?
    end

  end
end