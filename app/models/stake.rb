class Stake < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :season
  belongs_to :bookedby, class_name: 'User'
  belongs_to :paymenttype, optional: true
  belongs_to :ethtransaction, optional: true
  mount_uploader :invoice, AttachmentUploader
  mount_uploader :paidconfirmation, AttachmentUploader
  before_validation :figure_special_fees
  validate :check_max_stakes
  after_create :add_to_activity_feed
  validates_presence_of :owner_id, :season_id, :bookedby_id, :owner_type, :price, :invoice_amount, :invoice_due
  after_create  :generate_invoice
  skip_callback :after_create, only: :generate_invoice
  has_many :activities, as: :item, dependent: :destroy
  belongs_to :blockchain_transaction, autosave: true, optional: true
  scope :by_season, -> (x) { where(season_id: x)}
  scope :paid, ->() { where(paid: true)}
  scope :booked_unpaid,  ->() { where('paid is not true')}
  scope :past_year, ->() { where(["created_at >= ?",  1.year.ago.strftime("%Y-%m-%d")])}

  def add_to_activity_feed
    Activity.create(user: self.bookedby, item: self, description: "bought",  addition: 0,
        extra: (self.owner != self.bookedby ? self.owner : nil))
  end


  def award_points!
    if self.blockchain_transaction_id.nil? && self.paid == true && self.ethtransaction_id.nil?
      api = BiathlonApi.new
      transaction = api.api_get("/stakes/#{id}/award_stake_points", { headers: {'X-User-Email': bookedby.email, 'X-User-Token': bookedby.authentication_token}})

      if transaction['status'] == 'success'
        return transaction
      else
        return transaction
      end
    end  
  end


  def with_vat?
    owner.charge_vat?
  end

  def check_max_stakes
    if owner.stakes.empty?
      errors.add(:amount, :can_only_have_15_percent) if (season.stake_count * 0.15).to_i <  amount
    else
      errors.add(:amount, :can_only_have_15_percent) if (season.stake_count * 0.15).to_i <  (amount + owner.stakes.by_season(season.id).sum(&:amount))
    end
  end

  def figure_special_fees
    self.invoice_due = 2.weeks.since
    self.invoice_amount = amount * price

    if owner.charge_vat?
      self.invoice_amount *= 1.24
    end
    if owner_type == User
      if owner.stakes.past_year.where(includes_membership_fee: true).empty?
        self.includes_membership_fee = true
      end
      if owner.stakes.where(includes_share: true).empty?
        self.includes_share = true
      end
    else
      if owner.is_member?
        if owner.stakes.past_year.where(includes_membership_fee: true).empty?
          self.includes_membership_fee = true
        end
        if owner.stakes.where(includes_share: true).empty?
          self.includes_share = true
        end
      else
        if owner.taxid.blank?
          if bookedby.stakes.past_year.where(includes_membership_fee: true).empty?
            self.includes_membership_fee = true
          end
          if bookedby.stakes.where(includes_share: true).empty?
            self.includes_share = true
          end
        end
      end
    end
  end

  def billable
    if owner_type == 'Group' && !owner.taxid.blank?
      owner
    else
      bookedby
    end
  end

  def viitenumero
     FIViite.generate(sprintf("1%05d", id))
  end

  def generate_invoice

    unless invoice.nil?

      view = ActionView::Base.new(ActionController::Base.view_paths.first, {})
      view.extend(ApplicationHelper)
      view.extend(Rails.application.routes.url_helpers)

      pdf = WickedPdf.new.pdf_from_string(
        view.render(template: 'stakes/invoice.pdf.erb', locals: {stake: self}),
          :page_size => "A4",
          :show_as_html => true,
          :disable_smart_shrinking => false
         )
       #Pass pdf to carrierwave and save url in assessment.assessment
       # Write it to tempfile
       tempfile = Tempfile.new(["invoice_#{sprintf('%06d', id)}", ".pdf"])
       tempfile.binmode
       tempfile.write pdf
       tempfile.close

       # Attach that tempfile to the invoice
       if invoice.blank?
         self.invoice = File.open tempfile.path
       end

       Stake.skip_callback(:create, :after, :generate_invoice)

       save(validate: false)

       Stake.set_callback(:create, :after, :generate_invoice)
    end

  end

end
