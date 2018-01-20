class StakeMailer < ActionMailer::Base
  default from: "info@kuusipalaa.fi"
  require 'open-uri'



  def new_stake(stake)
    recipient = stake.bookedby
    @user = recipient
    @stake = stake
    attachments["invoice_000#{@stake.id.to_s}.pdf"] = open(@stake.invoice.url).read

    unless recipient.email =~ /^change@me/ #|| recipient.opt_in != true
      mail(to: recipient.email,  subject: "Kuusi Palaa stake confirmation for #{stake.owner.name}")
    end

  end


end
