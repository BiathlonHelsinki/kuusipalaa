class Stake < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :season
  belongs_to :bookedby, class_name: 'User'
  mount_uploader :invoice, AttachmentUploader
  mount_uploader :paidconfirmation, AttachmentUploader
  before_create :figure_special_fees
  validate :check_max_stakes

  validates_presence_of :owner_id, :season_id, :bookedby_id, :owner_type
  after_commit  :generate_invoice
  skip_callback :after_commit, only: :generate_invoice

  scope :by_season, -> (x) { where(season_id: x)}
  scope :paid, ->() { where(paid: true)}
  scope :booked_unpaid,  ->() { where('paid is not true')}
  scope :past_year, ->() { where(["created_at >= ?",  1.year.ago.strftime("%Y-%m-%d")])}


  def check_max_stakes
    errors.add(:amount, :can_only_have_15_percent) if (season.stake_count * 0.15).to_i <  (amount + owner.stakes.by_season(season.id).sum(&:amount))
  end

  def figure_special_fees
    self.invoice_due = 2.weeks.since
    # if owner.stakes.empty?
    #   self.includes_share = true
    #   self.includes_membership_fee = true
    # end
    if owner.stakes.past_year.where(includes_membership_fee: true).empty?
      self.includes_membership_fee = true
    end
    if owner.stakes.where(includes_share: true).empty?
      self.includes_share = true
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

       Stake.skip_callback(:commit, :after, :generate_invoice)

       save(validate: false)

       Stake.set_callback(:commit, :after, :generate_invoice)
    end

  end

end
