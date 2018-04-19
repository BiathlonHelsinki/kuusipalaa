class Activity < ApplicationRecord
  include PgSearch
  pg_search_scope :search_activity_feed, :against => [:description], associated_against: {user: [:name, :username], contributor: [:name, :username], instance: [translations: [:name]], event: [:name], ethtransaction: :txaddress }

  include Rails.application.routes.url_helpers
  belongs_to :contributor, polymorphic: true, optional: true
  belongs_to :user
  belongs_to :ethtransaction, optional: true
  belongs_to :blockchain_transaction, optional: true
  belongs_to :item, polymorphic: true
  belongs_to :extra, polymorphic: true, optional: true
  belongs_to :onetimer, optional: true
  has_one :instances_user
  validates_presence_of :item_id, :item_type

  scope :by_user, ->(user_id) { where(user_id: user_id) }


  def icon_class
    case description.to_s
    when 'attended','attended_anonymously','received_from', 'pledged_to','received_stake_points', 'edited_their_pledge_to','migrated_temps_from_temporary','was_credited_for','was_decredited_for','bought','withdrew_a_pledge','had_blockchain_balance_adjusted_by','spent_a_pledge_on'
      'icon-points'
    when 'asked_the_question','answered_the_question', 'shared_an_image_from'
      'icon-actions'
    when 'proposed','published_event',  'cancelled_it', 'plans_to_attend', 'registered_for', 'is_no_longer_planning_to_attend','is_no_longer_registered_for','booked_the_back_room_on'
      'icon-event'
    when 'joined', 'linked', 'edited_the_group', 'was_added_to_the_group','created_the_group'
      'icon-profile'     
    else
      'icon-other'

    end
  end

  def linked_name

    case item.class.to_s
    when 'Credit'
      item.name
    when 'Pledge'
      if item.item.class == Proposal
        "<a href='/proposals/#{item.item.id}'>#{item.item.name}</a>"
      else
        "<a href='/events/#{item.item.slug}'>#{item.item.name}</a>"
      end
    when 'Proposal'
      out = "<a href='/proposals/#{item.id}'>#{item.name}</a>"
      if description =~ /status/ && description =~ /changed/
        out += extra_info
      end
      out
    when 'NilClass'
      if item_type == 'Nfc'
        'erased an ID card'
      else
        item_type.constantize.with_deleted.find(item_id).name
      end
    when 'Userphotoslot'
      unless item.userphoto.nil?
        if item.userphoto.instance
          I18n.t(:used_on_event, instance: "<a href='/events/#{item.userphoto.instance.event.slug}/#{item.userphoto.instance.slug}'>#{item.userphoto.instance.name}</a>" )
        end
      end
    when 'Roombooking'
      "<a href='/roombookings/'>#{item.day.strftime('%-d %B %Y')}</a> " + extra_info.to_s || ''
    when 'User'
      if value
        "#{item.display_name}  <br /><small>#{extra_info}</small>"
      elsif extra
        "<a href='/users/" + item.slug + "'>" + item.display_name + "</a> #{I18n.t(extra_info.to_sym)} <a href='/" + extra.class.table_name + "/#{extra.id.to_s}'>" + extra.name + "</a>"
      elsif description =~ /joined/
        ''
      else
        "<a href='/users/" + item.slug + "'>" + item.display_name + "</a>"

      end
    when 'Instance'
      "<a href='/events/#{item.event.slug}/#{item.slug}'>#{item.name}</a>"
    when 'Nfc'
      "an ID card"
    when 'Post'
      "<a href='/posts/#{item.slug}'>by the #{ENV['currency_symbol']}empsBot</a>"
    when 'Event'
      "<a href='/experiments/#{item.slug}'>#{item.name}</a>"
    end
  end
  #
  #   - if activity.item.class == NilClass
  #     = activity.item_type.constantize.with_deleted.find(activity.item_id).name
  #   - else
  #     - begin
  #       = link_to activity.item.name, activity.item, target: :_blank
  #     - rescue NoMethodError
  #       = activity.item.name
  # end

  def sentence
    if user_id == 0
      usertext= 'Somebody'
    elsif user.nil?
      usertext = 'Someone who does not exist with id ' + user_id.to_s
    else
      usertext = "#{user.display_name} (<a href='/users/#{user.slug}/activities'>#{user.display_name}</a>)"
    end
    if item.class == Proposal
      "#{usertext} #{description} <a href='/proposals/#{item.id}'>#{item.name}</a> #{extra_info}"
    elsif item.class == User
      "#{usertext} #{description} <a href='users/#{item.slug}'>#{item.name}</a> #{extra_info}"
    elsif item.class == Credit
      if blockchain_transaction
        "#{usertext} #{description} <a href='credits/#{item.id}'>#{item.description}</a> and received  #{blockchain_transaction.value}#{ENV['currency_symbol']}"
      else
        "#{usertext} #{description} <a href='credits/#{item.id}'>#{item.description}</a> and received  #{item.value}#{ENV['currency_symbol']}"
      end
    elsif item.class == NilClass
      dead_item = item_type.constantize.with_deleted.find(item_id) rescue 'something is not right here'
      "#{usertext} #{description} #{dead_item.description} and #{dead_item.value}#{ENV['currency_symbol']} were returned to the blockchain"
    elsif item.class == Pledge
      "#{usertext} #{description} #{linked_name} #{extra_info}"
    elsif item.class == Post
      "#{usertext} #{description} by the TempsBot"
    elsif item.class == Roombooking
      "#{usertext} #{description}"
    elsif item.class == Userphotoslot
      "#{usertext} #{description}"
    elsif item.class == Event
       "#{usertext} #{description}"
    else
      "#{usertext} #{description} <a href='/events/#{item.event.slug}/#{item.slug}'>#{item.name}</a> and received #{item.cost_bb}#{ENV['currency_symbol']}"
    end
  end

  def value
    if item.class == Pledge
      item.pledge.to_i
    elsif blockchain_transaction
      if blockchain_transaction.transaction_type_id == 2 && description =~ /blockchain/
        blockchain_transaction.value.to_i * -1
      else
        blockchain_transaction.value
      end
    elsif ethtransaction
      ethtransaction.value.to_i
    elsif extra.nil? && (description !~ /changed/ && description !~ /status/ && description !~ /cancelled/)
      extra_info
    else
      nil
    end

  end

  def uniq_contributor
    if description == 'attended_anonymously'
      id
    else
      contributor
    end
  end

end
