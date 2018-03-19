class NotificationMailer < ActionMailer::Base
  default from: "info@kuusipalaa.fi"
  default "Message-ID" => lambda {"<#{SecureRandom.uuid}@kuusipalaa.fi>"}

  def new_comment(item, comment, recipient)
    @item = item
    @comment = comment
    @user = recipient
    unless recipient.email =~ /^change@me/ || recipient.opt_in != true
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
