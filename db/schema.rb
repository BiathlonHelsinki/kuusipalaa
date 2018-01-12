# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171121123419) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_trgm"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "address", limit: 42, null: false
    t.integer "user_id"
    t.integer "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "external"
    t.boolean "primary_account"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "ethtransaction_id"
    t.string "item_type"
    t.integer "item_id"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "onetimer_id"
    t.string "extra_info"
    t.integer "addition", default: 0, null: false
    t.string "extra_type"
    t.integer "extra_id"
    t.string "txaddress"
    t.integer "blockchain_transaction_id"
    t.integer "numerical_value"
    t.index ["ethtransaction_id"], name: "index_activities_on_ethtransaction_id"
    t.index ["extra_type", "extra_id"], name: "index_activities_on_extra_type_and_extra_id"
    t.index ["item_type", "item_id"], name: "index_activities_on_item_type_and_item_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authentications", id: :serial, force: :cascade do |t|
    t.string "provider"
    t.string "username"
    t.string "uid"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "provider", "uid"], name: "index_authentications_on_user_id_and_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "blockchain_transactions", id: :serial, force: :cascade do |t|
    t.integer "transaction_type_id"
    t.integer "account_id"
    t.integer "ethtransaction_id"
    t.integer "value"
    t.datetime "submitted_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recipient_id"
    t.index ["account_id"], name: "index_blockchain_transactions_on_account_id"
    t.index ["ethtransaction_id"], name: "index_blockchain_transactions_on_ethtransaction_id"
    t.index ["transaction_type_id"], name: "index_blockchain_transactions_on_transaction_type_id"
  end

  create_table "ckeditor_assets", id: :serial, force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.integer "assetable_id"
    t.string "assetable_type", limit: 30
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable"
    t.index ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "item_type"
    t.integer "item_id"
    t.integer "user_id"
    t.text "content"
    t.string "image"
    t.string "image_content_type"
    t.integer "image_size"
    t.integer "image_width"
    t.integer "image_height"
    t.string "attachment"
    t.integer "attachment_size"
    t.string "attachment_content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "systemflag", default: false, null: false
    t.boolean "frontpage", default: false, null: false
    t.index ["item_type", "item_id"], name: "index_comments_on_item_type_and_item_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "credits", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "awarder_id"
    t.string "description"
    t.integer "ethtransaction_id"
    t.string "attachment"
    t.string "attachment_content_type"
    t.integer "attachment_size"
    t.integer "value"
    t.integer "rate_id"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_credits_on_deleted_at"
    t.index ["ethtransaction_id"], name: "index_credits_on_ethtransaction_id"
    t.index ["rate_id"], name: "index_credits_on_rate_id"
    t.index ["user_id"], name: "index_credits_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.datetime "sent_at"
    t.boolean "sent", default: false, null: false
    t.text "body"
    t.string "subject"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sent_number"
  end

  create_table "eras", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ethtransactions", id: :serial, force: :cascade do |t|
    t.integer "transaction_type_id", null: false
    t.string "txaddress", limit: 66, null: false
    t.string "source_account"
    t.string "recipient_account"
    t.integer "source_user"
    t.integer "recipient_user"
    t.integer "value"
    t.datetime "timeof"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "credit_id"
    t.boolean "confirmed", default: false, null: false
    t.datetime "checked_confirmation_at"
    t.index ["transaction_type_id"], name: "index_ethtransactions_on_transaction_type_id"
  end

  create_table "event_translations", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.index ["event_id"], name: "index_event_translations_on_event_id"
    t.index ["locale"], name: "index_event_translations_on_locale"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.integer "place_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "published"
    t.integer "primary_sponsor_id"
    t.integer "secondary_sponsor_id"
    t.string "slug"
    t.float "cost_euros"
    t.integer "cost_bb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.string "image_content_type"
    t.integer "image_size"
    t.integer "image_width"
    t.integer "image_height"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.string "sequence"
    t.integer "proposal_id"
    t.boolean "collapse_in_website", default: false, null: false
    t.boolean "stopped"
    t.index ["place_id"], name: "index_events_on_place_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.text "description"
    t.string "avatar"
    t.string "avatar_content_type"
    t.integer "avatar_size"
    t.integer "avatar_width"
    t.integer "avatar_height"
    t.string "slug"
    t.string "website"
    t.string "twitter_name"
    t.string "geth_pwd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "long_name"
    t.string "avatar_tmp"
  end

  create_table "hardwares", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.macaddr "mac_address"
    t.text "description"
    t.string "authentication_token", limit: 30
    t.integer "hardwaretype_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "checkable"
    t.datetime "last_checked_at"
    t.boolean "notified_of_error"
    t.index ["authentication_token"], name: "index_hardwares_on_authentication_token", unique: true
    t.index ["hardwaretype_id"], name: "index_hardwares_on_hardwaretype_id"
    t.index ["slug"], name: "index_hardwares_on_slug", unique: true
  end

  create_table "hardwaretypes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_hardwaretypes_on_slug", unique: true
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "image"
    t.string "image_content_type"
    t.integer "image_size"
    t.integer "image_width"
    t.integer "image_height"
    t.string "item_type"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_images_on_item_type_and_item_id"
  end

  create_table "instance_translations", id: :serial, force: :cascade do |t|
    t.integer "instance_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.index ["instance_id"], name: "index_instance_translations_on_instance_id"
    t.index ["locale"], name: "index_instance_translations_on_locale"
  end

  create_table "instances", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "cost_bb"
    t.float "cost_euros"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "place_id"
    t.boolean "published"
    t.string "image"
    t.string "image_content_type"
    t.integer "image_height"
    t.integer "image_width"
    t.integer "image_size"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sequence"
    t.boolean "is_meeting"
    t.integer "proposal_id"
    t.boolean "allow_multiple_entry"
    t.boolean "spent_biathlon", default: false, null: false
    t.boolean "request_rsvp"
    t.boolean "request_registration"
    t.float "custom_bb_fee"
    t.string "email_registrations_to"
    t.string "question1_text"
    t.string "question2_text"
    t.string "question3_text"
    t.string "question4_text"
    t.string "boolean1_text"
    t.string "boolean2_text"
    t.boolean "require_approval"
    t.boolean "hide_registrants"
    t.boolean "show_guests_to_public"
    t.integer "max_attendees"
    t.boolean "registration_open", default: true, null: false
    t.boolean "cancelled", default: false, null: false
    t.boolean "survey_locked"
    t.index ["event_id"], name: "index_instances_on_event_id"
    t.index ["place_id"], name: "index_instances_on_place_id"
    t.index ["proposal_id"], name: "index_instances_on_proposal_id"
  end

  create_table "instances_organisers", id: :serial, force: :cascade do |t|
    t.integer "instance_id"
    t.integer "organiser_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id", "organiser_id"], name: "instances_organisers_instance_id_organiser_id_key", unique: true
    t.index ["instance_id"], name: "index_instances_organisers_on_instance_id"
  end

  create_table "instances_users", id: :serial, force: :cascade do |t|
    t.integer "instance_id", null: false
    t.integer "user_id", null: false
    t.date "visit_date"
    t.integer "activity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_instances_users_on_activity_id"
    t.index ["user_id", "instance_id", "visit_date"], name: "index_instances_users_on_user_id_and_instance_id_and_visit_date", unique: true
  end

  create_table "meeting_translations", force: :cascade do |t|
    t.integer "meeting_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.index ["locale"], name: "index_meeting_translations_on_locale"
    t.index ["meeting_id"], name: "index_meeting_translations_on_meeting_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.bigint "place_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.bigint "era_id"
    t.string "image"
    t.string "image_content_type"
    t.integer "image_size"
    t.integer "image_width"
    t.integer "image_height"
    t.string "slug"
    t.boolean "published"
    t.boolean "cancelled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["era_id"], name: "index_meetings_on_era_id"
    t.index ["place_id"], name: "index_meetings_on_place_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "source_type"
    t.bigint "source_id"
    t.bigint "user_id"
    t.integer "access_level"
    t.integer "notification_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_members_on_source_type_and_source_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "nfcs", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "tag_address", limit: 20
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "security_code"
    t.datetime "last_used"
    t.boolean "keyholder", default: false, null: false
    t.index ["tag_address"], name: "index_nfcs_on_tag_address", unique: true
    t.index ["user_id"], name: "index_nfcs_on_user_id"
  end

  create_table "nodes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.boolean "is_open", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "item_type"
    t.integer "item_id"
    t.integer "user_id"
    t.boolean "pledges"
    t.boolean "comments"
    t.boolean "scheduling"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_notifications_on_item_type_and_item_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "onetimers", id: :serial, force: :cascade do |t|
    t.integer "instance_id"
    t.string "code", limit: 7
    t.boolean "claimed", default: false, null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_onetimers_on_code", unique: true
    t.index ["instance_id"], name: "index_onetimers_on_instance_id"
    t.index ["user_id"], name: "index_onetimers_on_user_id"
  end

  create_table "opensessions", id: :serial, force: :cascade do |t|
    t.integer "node_id", null: false
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_opensessions_on_node_id"
    t.index ["node_id"], name: "null_valid_from", unique: true, where: "(closed_at IS NULL)"
  end

  create_table "page_translations", id: :serial, force: :cascade do |t|
    t.integer "page_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "body"
    t.index ["locale"], name: "index_page_translations_on_locale"
    t.index ["page_id"], name: "index_page_translations_on_page_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.boolean "published"
    t.string "slug"
    t.string "image"
    t.string "image_content_type"
    t.integer "image_size"
    t.integer "image_height"
    t.integer "image_width"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.integer "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "place_translations", id: :serial, force: :cascade do |t|
    t.integer "place_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["locale"], name: "index_place_translations_on_locale"
    t.index ["place_id"], name: "index_place_translations_on_place_id"
  end

  create_table "places", id: :serial, force: :cascade do |t|
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "country"
    t.string "postcode"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pledges", id: :serial, force: :cascade do |t|
    t.string "item_type"
    t.integer "item_id"
    t.integer "user_id"
    t.integer "pledge"
    t.string "comment"
    t.integer "converted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "extra_info"
    t.integer "instance_id"
    t.index ["item_type", "item_id"], name: "index_pledges_on_item_type_and_item_id"
    t.index ["user_id"], name: "index_pledges_on_user_id"
  end

  create_table "post_translations", id: :serial, force: :cascade do |t|
    t.integer "post_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "body"
    t.index ["locale"], name: "index_post_translations_on_locale"
    t.index ["post_id"], name: "index_post_translations_on_post_id"
  end

  create_table "postcategories", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "postcategory_translations", id: :serial, force: :cascade do |t|
    t.integer "postcategory_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["locale"], name: "index_postcategory_translations_on_locale"
    t.index ["postcategory_id"], name: "index_postcategory_translations_on_postcategory_id"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.boolean "published"
    t.integer "user_id"
    t.datetime "published_at"
    t.string "image"
    t.integer "image_width"
    t.integer "image_height"
    t.string "image_content_type"
    t.integer "image_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sticky"
    t.integer "instance_id"
    t.integer "postcategory_id"
    t.integer "era_id"
    t.integer "meeting_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "proposals", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.text "short_description"
    t.string "timeframe"
    t.text "goals"
    t.string "intended_participants"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comment_count", default: 0
    t.boolean "notified"
    t.boolean "scheduled"
    t.boolean "allow_rescheduling"
    t.integer "recurrence"
    t.integer "intended_sessions"
    t.boolean "stopped", default: false, null: false
    t.integer "proposalstatus_id"
    t.integer "total_needed_with_recurrence_cached"
    t.string "needed_array_cached"
    t.boolean "has_enough_cached"
    t.integer "number_that_can_be_scheduled_cached"
    t.boolean "pledgeable_cached"
    t.integer "pledged_cached"
    t.integer "remaining_pledges_cached"
    t.integer "spent_cached"
    t.integer "published_instances", default: 0, null: false
    t.integer "duration", default: 1
    t.boolean "is_month_long", default: false, null: false
    t.boolean "require_all", default: false, null: false
    t.index ["user_id"], name: "index_proposals_on_user_id"
  end

  create_table "proposalstatus_translations", id: :serial, force: :cascade do |t|
    t.integer "proposalstatus_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["locale"], name: "index_proposalstatus_translations_on_locale"
    t.index ["proposalstatus_id"], name: "index_proposalstatus_translations_on_proposalstatus_id"
  end

  create_table "proposalstatuses", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rates", id: :serial, force: :cascade do |t|
    t.boolean "current"
    t.integer "experiment_cost"
    t.float "euro_exchange"
    t.integer "instance_id"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "room_cost", default: 25, null: false
    t.index ["instance_id"], name: "index_rates_on_instance_id"
  end

  create_table "registrations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "instance_id"
    t.string "phone"
    t.text "question1"
    t.text "question2"
    t.boolean "boolean1"
    t.boolean "boolean2"
    t.text "question3"
    t.text "question4"
    t.boolean "approved"
    t.boolean "waiting_list", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_registrations_on_instance_id"
    t.index ["user_id"], name: "index_registrations_on_user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "roombookings", id: :serial, force: :cascade do |t|
    t.date "day", null: false
    t.integer "user_id", null: false
    t.integer "ethtransaction_id"
    t.integer "rate_id", null: false
    t.string "purpose"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_roombookings_on_day", unique: true
    t.index ["ethtransaction_id"], name: "index_roombookings_on_ethtransaction_id"
    t.index ["rate_id"], name: "index_roombookings_on_rate_id"
    t.index ["user_id"], name: "index_roombookings_on_user_id"
  end

  create_table "rsvps", id: :serial, force: :cascade do |t|
    t.integer "instance_id"
    t.integer "user_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "meeting_id"
    t.index ["instance_id", "user_id"], name: "index_rsvps_on_instance_id_and_user_id", unique: true
    t.index ["instance_id"], name: "index_rsvps_on_instance_id"
    t.index ["user_id"], name: "index_rsvps_on_user_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "number"
    t.date "start_at"
    t.date "end_at"
    t.integer "stake_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.hstore "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stakes", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.boolean "paid", default: false, null: false
    t.bigint "season_id"
    t.string "notes"
    t.datetime "paid_at"
    t.string "invoice"
    t.string "invoice_content_type"
    t.integer "invoice_size"
    t.integer "amount", default: 1, null: false
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bookedby_id"
    t.index ["owner_type", "owner_id"], name: "index_stakes_on_owner_type_and_owner_id"
    t.index ["season_id"], name: "index_stakes_on_season_id"
  end

  create_table "surveys", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "never_visited"
    t.text "experiment_why"
    t.text "platform_benefits"
    t.text "different_contribution"
    t.text "welcoming_concept"
    t.text "physical_environment"
    t.text "website_etc"
    t.text "different_than_others"
    t.text "your_space"
    t.boolean "allow_excerpt"
    t.boolean "allow_identity"
    t.boolean "completed"
    t.text "features_benefit"
    t.text "improvements"
    t.text "clear_structure"
    t.text "want_from_culture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_surveys_on_user_id"
  end

  create_table "transaction_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "factorial", default: 0
  end

  create_table "userlinks", id: :serial, force: :cascade do |t|
    t.string "url"
    t.integer "user_id"
    t.integer "instance_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_userlinks_on_instance_id"
    t.index ["user_id"], name: "index_userlinks_on_user_id"
  end

  create_table "userphotos", id: :serial, force: :cascade do |t|
    t.string "image"
    t.integer "image_file_size"
    t.string "image_content_type"
    t.integer "image_width"
    t.integer "image_height"
    t.integer "instance_id"
    t.integer "user_id"
    t.string "credit", limit: 100
    t.string "caption", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "karma", default: 0, null: false
    t.index ["instance_id"], name: "index_userphotos_on_instance_id"
    t.index ["user_id"], name: "index_userphotos_on_user_id"
  end

  create_table "userphotoslots", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "userphoto_id"
    t.integer "ethtransaction_id"
    t.integer "activity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_userphotoslots_on_activity_id"
    t.index ["ethtransaction_id"], name: "index_userphotoslots_on_ethtransaction_id"
    t.index ["user_id"], name: "index_userphotoslots_on_user_id"
    t.index ["userphoto_id"], name: "index_userphotoslots_on_userphoto_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "username"
    t.string "authentication_token"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "name"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "latest_balance", default: 0, null: false
    t.datetime "latest_balance_checked_at"
    t.string "geth_pwd"
    t.boolean "show_name", default: false, null: false
    t.string "avatar"
    t.string "avatar_content_type"
    t.integer "avatar_size"
    t.integer "avatar_width"
    t.integer "avatar_height"
    t.boolean "opt_in", default: true
    t.string "website"
    t.text "about_me"
    t.string "twitter_name"
    t.string "address"
    t.string "postcode"
    t.string "city"
    t.string "country"
    t.boolean "show_twitter_link", default: false, null: false
    t.boolean "show_facebook_link", default: false, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "avatar_tmp"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  create_table "userthoughts", id: :serial, force: :cascade do |t|
    t.integer "instance_id"
    t.integer "user_id"
    t.text "thoughts"
    t.integer "karma"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_userthoughts_on_instance_id"
    t.index ["user_id"], name: "index_userthoughts_on_user_id"
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "activities", "ethtransactions"
  add_foreign_key "authentications", "users"
  add_foreign_key "blockchain_transactions", "accounts"
  add_foreign_key "blockchain_transactions", "ethtransactions"
  add_foreign_key "blockchain_transactions", "transaction_types"
  add_foreign_key "comments", "users"
  add_foreign_key "credits", "ethtransactions"
  add_foreign_key "credits", "rates"
  add_foreign_key "credits", "users"
  add_foreign_key "ethtransactions", "transaction_types"
  add_foreign_key "events", "places"
  add_foreign_key "hardwares", "hardwaretypes"
  add_foreign_key "instances", "events"
  add_foreign_key "instances", "places"
  add_foreign_key "instances_organisers", "instances"
  add_foreign_key "meetings", "eras"
  add_foreign_key "meetings", "places"
  add_foreign_key "members", "users"
  add_foreign_key "nfcs", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "onetimers", "users"
  add_foreign_key "opensessions", "nodes"
  add_foreign_key "pledges", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "proposals", "users"
  add_foreign_key "rates", "instances"
  add_foreign_key "registrations", "instances"
  add_foreign_key "registrations", "users"
  add_foreign_key "roombookings", "ethtransactions"
  add_foreign_key "roombookings", "rates"
  add_foreign_key "roombookings", "users"
  add_foreign_key "rsvps", "instances"
  add_foreign_key "rsvps", "users"
  add_foreign_key "stakes", "seasons"
  add_foreign_key "surveys", "users"
  add_foreign_key "userlinks", "instances"
  add_foreign_key "userlinks", "users"
  add_foreign_key "userphotos", "instances"
  add_foreign_key "userphotos", "users"
  add_foreign_key "userphotoslots", "activities"
  add_foreign_key "userphotoslots", "ethtransactions"
  add_foreign_key "userphotoslots", "userphotos"
  add_foreign_key "userphotoslots", "users"
  add_foreign_key "userthoughts", "instances"
  add_foreign_key "userthoughts", "users"
end
