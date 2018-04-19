class Credit < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  belongs_to :awarder, class_name: 'User'
  belongs_to :ethtransaction
  belongs_to :rate
  mount_uploader :attachment, AttachmentUploader
  has_many :activities, as: :item,  dependent: :destroy
  before_save :update_attachment_metadata
  validates_numericality_of :value, :greater_than_or_equal_to => 0
  validates_presence_of :user_id, :awarder_id, :description, :value, :rate_id
  
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  
  # before_save :award_points
  #
  # def award_points
  #   # check if user has ethereum account yet
  #   if user.accounts.empty?
  #     create_call = HTTParty.post(Figaro.env.dapp_address + '/create_account', body: {password: user.geth_pwd})
  #     unless JSON.parse(create_call.body)['data'].blank?
  #       user.accounts << Account.create(address: JSON.parse(create_call.body)['data'], primary_account: true)
  #       user.save
  #     end
  #   end
  #   # account is created in theory, so now let's do the transaction
  #   api = BidappApi.new
  #   transaction = api.mint(user.accounts.primary.first.address, value)
  #   user.accounts.primary.first.balance = user.accounts.primary.first.balance.to_i + value
  #   user.save(validate: false)
  #   # get transaction hash and add to activity feed. TODO: move to concern!!
  #   Activity.create(user: user, item: self, ethtransaction: Ethtransaction.find_by(txaddress: transaction), description: 'was credited for')
  #   return true
  # end
  
  def name
    description
  end
  
  private
  
  def update_attachment_metadata
     if attachment.present? && attachment_changed?
       if attachment.file.exists?
         self.attachment_content_type = attachment.file.content_type
         self.attachment_size = attachment.file.size
       end
     end
   end
   
end
