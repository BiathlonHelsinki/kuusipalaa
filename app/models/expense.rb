class Expense < ApplicationRecord
  validates_presence_of :recipient, :date_spent, :amount, :alv
  mount_uploader :receipt, ProtectedAttachmentUploader
end
