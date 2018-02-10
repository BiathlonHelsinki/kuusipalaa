class Idea < ApplicationRecord
  belongs_to :proposer, polymorphic: true, optional: true
  belongs_to :parent, polymorphic: true, optional: true
  belongs_to :proposalstatus, optional: true
  belongs_to :ideatype
  has_many :additionaltimes, as: :item
  validates :start_at, :end_at, :proposer_type, :proposer_id, :name, :short_description, :proposal_text, :ideatype_id, :presence => true, :if => :active?

  accepts_nested_attributes_for :additionaltimes, reject_if: proc {|x| x['start_at'].blank? || x['end_at'].blank? }
  
  extend FriendlyId
  friendly_id :name

  mount_uploader :image, ImageUploader
  before_save :update_image_attributes



  def active?
    status == 'active'
  end

  def start_at_date
    start_at.nil? ? nil : start_at.strftime('%Y-%m-%d')
  end

  def end_at_date
    end_at.nil? ? nil : end_at.strftime('%Y-%m-%d')
  end
  private

  def update_image_attributes

    if image.present? && image?

      if image.file.exists?
        self.image_content_type = image.file.content_type
        self.image_size = image.file.size
        self.image_width, self.image_height = `identify -format "%wx%h" #{image.file.path}`.split(/x/) rescue nil
      end
    end
  end

end
