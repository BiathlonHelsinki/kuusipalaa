class Bankstatement < ApplicationRecord
  mount_uploader :pdf, ProtectedAttachmentUploader
  validates_presence_of :month, :year, :pdf
  before_save :update_pdf_attributes
  
  private

  def update_pdf_attributes
    if pdf.present? && pdf_changed?
      if pdf.file.exists?
        self.pdf_content_type = pdf.file.content_type
        self.pdf_size = pdf.file.size
      end
    end
  end

end
