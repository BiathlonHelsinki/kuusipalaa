class TransfersMailer < ActionMailer::Base
  default from: "info@kuusipalaa.fi"
  default "Message-ID" => lambda {"<#{SecureRandom.uuid}@kuusipalaa.fi>"}
  
  def received_points(sender, recipient, amount, reason = nil)
    @sender = sender
    @recipient = recipient
    @amount = amount
    @reason = reason
    unless recipient.email =~ /change@me/
      mail(to: recipient.email,  subject: "You've got points! (from #{@sender.display_name})")
    end    
  end


end
