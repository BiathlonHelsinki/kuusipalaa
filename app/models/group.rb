class Group < ApplicationRecord
  has_many :members, dependent: :destroy, as: :source
  has_many :users, through: :members
  has_many :stakes, dependent: :destroy, as: :owner
  has_many :owners,
   -> { where(members: { access_level: KuusiPalaa::Access::OWNER }) },
   through: :members,
   source: :user
  extend FriendlyId
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
  before_save :validate_vat
  validates_presence_of :geth_pwd
  has_many :activities, as: :contributor
  rolify
  
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
    Activity.create(user: self.members.first.user, item: self, description: "edited_the_group",  addition: 0)
  end

  def add_to_activity_feed
    Activity.create(user: self.members.first.user, item: self, description: "created_the_group",  addition: 0)
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
