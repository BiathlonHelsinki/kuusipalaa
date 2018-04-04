class Group < ApplicationRecord
  has_many :members, dependent: :destroy, as: :source
  has_many :users, through: :members
  has_many :stakes, dependent: :destroy, as: :owner
  before_save :validate_vat
  has_many :activities, as: :contributor
  has_many :ideas, as: :proposer
  has_many :pledges, as: :pledger
  has_many :owners,
   -> { where(members: { access_level: KuusiPalaa::Access::OWNER }) },
   through: :members,
   source: :user
  has_many :privileged,
   -> { where(members: { access_level: KuusiPalaa::Access::REGULAR_MEMBER..KuusiPalaa::Access::OWNER}) },
   through: :members,
   source: :user 
  extend FriendlyId
  has_many :accounts, as: :holder
  friendly_id :name , :use => [ :slugged, :finders, :history]
  mount_uploader :avatar, ImageUploader
  before_save :update_avatar_attributes
  # process_in_background :avatar
  validates_presence_of :name
  validate :uniqueness_of_a_name
  before_validation :copy_password
  before_create :at_least_one_member
  after_create :add_to_activity_feed
  after_update :edit_to_activity_feed
  validates_presence_of :geth_pwd
  has_many :budgetproposal_votes, as: :voter
  has_many :budgetproposals, as: :proposer

  rolify
  
  def available_balance
    latest_balance - pending_pledges.sum(&:pledge)
  end

  def pending_pledges
     pledges.unconverted
  end

  def all_peers
    members.to_a.delete_if{|x| x.access_level < 5 }.map(&:user).flatten.uniq
  end


  def update_balance_from_blockchain
    api = BiathlonApi.new
    balance = api.api_get("/users/#{id}/get_balance")
    if balance
      unless balance.class == Hash
        latest_balance = balance.to_i
        latest_balance_checked_at = Time.now.to_i
        save(validate: false)
      end
    end

  end

  def is_stakeholder?
    if is_member && !taxid.blank?
      return !stakes.paid.empty?
    else
      if taxid.blank?
        return !stakes.paid.empty?
      else
        return false
      end
    end
  end
  
  def keys
    members.select{|x| x.has_key == true}.map(&:user)
  end

  def keys_left
    (stakes.paid.sum(&:amount) * 5) - keys.size
  end

  def validate_vat
    unless taxid.blank?
      unless country == 'FI' || country.blank?
        self.valid_vat_number = Valvat.new(taxid).valid?
      else
        self.valid_vat_number = false
      end
    else
      self.valid_vat_number = false
    end
  end

  def at_least_one_member

  end

  def stake_price
    if is_member && !taxid.blank?
      return 75
    else
      if taxid.blank?
        return 50
      else
        return 100
      end
    end
  end

  def copy_password
    if geth_pwd.blank?
      self.geth_pwd = SecureRandom.hex(13)
    end
  end

  def charge_vat?
    if is_member
      return false
    else  #could be unregistered
      if !taxid.blank?
        if country == 'FI'
          return true
        else
          if valid_vat_number == true
            return false
          else
            return true
          end
        end
      else
        return false
      end
    end
  end

  def display_name
    if long_name.blank?
      name
    else
      long_name
    end
  end

  def uniqueness_of_a_name
    self.errors.add(:name, 'is already taken') if User.where("lower(username) = ?", self.name.downcase).exists?
    if new_record?
      self.errors.add(:name, 'is already taken') if Group.where(["lower(name) = ? ", self.name.downcase]).exists?
    else
      self.errors.add(:name, 'is already taken') if Group.where("lower(name) = ? and id <> ?", self.name.downcase, self.id).exists?
    end
  end

  def edit_to_activity_feed
    Activity.create(user: self.members.first.user, contributor: self.members.first.user, item: self, description: "edited_the_group",  addition: 0)
  end

  def add_to_activity_feed
    Activity.create(user: self.members.first.user, contributor: self.members.first.user, item: self, description: "created_the_group",  addition: 0)
  end

  def update_avatar_attributes
    if avatar.present? && avatar_changed?
      if avatar.file.exists?
        self.avatar_content_type = avatar.file.content_type
        self.avatar_size = avatar.file.size rescue 0
        self.avatar_width, self.avatar_height = `identify -format "%wx%h" #{avatar.file.path}`.split(/x/) rescue nil
      end
    end
  end

end
