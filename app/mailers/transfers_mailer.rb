class TransfersMailer < ActionMailer::Base
  default from: "info@kuusipalaa.fi"
  default "Message-ID" => lambda {"<#{SecureRandom.uuid}@kuusipalaa.fi>"}
  
  def received_points(sender, recipient, amount, reason = nil)
    @sender = sender
    @recipient = recipient
    @amount = amount
    @reason = reason
    if recipient.class == User
      unless recipient.email =~ /change@me/ || recipient.opt_out_everything == true || recipient.opt_in_points != true
        mail(to: recipient.email,  subject: "You've got points! (from #{@sender.display_name})")
      end    
    elsif recipient.class == Group
      recipient.owners.each do |owner|
        unless owner.email =~ /change@me/ || owner.opt_out_everything == true || owner.opt_in_points != true
          mail(to: owner.email,  subject: "#{recipient.name} has received points! (from #{@sender.display_name})")
        end 
      end
    end
  end
  
end
