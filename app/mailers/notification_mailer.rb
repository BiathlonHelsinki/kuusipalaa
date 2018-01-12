class NotificationMailer < ActionMailer::Base
  default from: "admin@temporary.fi"
  
 
  def new_comment(item, comment, recipient)
    @item = item
    @comment = comment
    @user = recipient
    unless recipient =~ /^change@me/ || recipient.opt_in != true
      mail(to: recipient.email,  subject: "New comment on: #{@item.name}") 
    end
    
  end
  
  def new_pledge(item, pledge, recipient)
    @item = item
    @pledge = pledge
    @user = recipient
    unless recipient =~ /^change@me/ || recipient.opt_in != true
      mail(to: recipient.email,  subject: "New pledge to proposal: #{@item.name}") 
    end
  end


  def new_scheduling(item, recipient)
    @item = item
    @user = recipient
    unless recipient =~ /^change@me/ || recipient.opt_in != true
      mail(to: recipient.email,  subject: "A new meeting of #{@item.event.name} has been scheduled") 
    end
    
  end

end
