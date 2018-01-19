class GroupMailer < ActionMailer::Base
  default from: "info@kuusipalaa.fi"


  def new_member(group, member)
    recipient = member.user
    @group = group
    @user = recipient
    unless recipient.email =~ /^change@me/ || recipient.opt_in != true
      mail(to: recipient.email,  subject: "You have been added to the group #{@group.display_name}")
    end

  end


end
