class Group < ApplicationRecord
  has_many :members, dependent: :destroy, as: :source
  has_many :users, through: :members
  has_many :stakes, dependent: :destroy, as: :owner
  has_many :owners,
   -> { where(members: { access_level: Experiment2::Access::OWNER }) },
   through: :members,
   source: :user
  extend FriendlyId
  friendly_id :name , :use => [ :slugged, :finders, :history]
  mount_uploader :avatar, ImageUploader
  before_save :update_avatar_attributes
  # process_in_background :avatar
  validates_presence_of :name
  validate :uniqueness_of_a_name
  after_create :add_to_activity_feed
  after_update :edit_to_activity_feed

  def display_name
    if long_name.blank?
      name
    else
      long_name
    end
  end

  def uniqueness_of_a_name
    self.errors.add(:name, 'is already taken') if User.where("lower(username) = ?", self.name).exists?
    self.errors.add(:name, 'is already taken') if Group.where("lower(name) = ? and id <> ?", self.name, self.id).exists?
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
