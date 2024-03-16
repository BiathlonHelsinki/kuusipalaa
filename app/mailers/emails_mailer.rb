class EmailsMailer < ActionMailer::Base
  include ActionView::Helpers::UrlHelper
  helper ApplicationHelper
  helper TruncateHtmlHelper
  default from: "info@kuusipalaa.fi"
  default "Message-ID" => -> { "<#{SecureRandom.uuid}@kuusipalaa.fi>" }

  def announcement(_address, email, user, announcements, upcoming_events, future_events, open_time, new_proposals, still_needing_pledges, markdown)
    @email = email
    @user = user
    @is_email = true
    @emailannouncements = announcements
    @upcoming_events = upcoming_events
    @future_events = future_events
    @open_time = open_time
    @new_proposals = new_proposals
    @still_needing_pledges = still_needing_pledges
    @markdown = markdown
    @next_season = begin
      Season.find(2)
    rescue StandardError
      "2"
    end
    @current_season = Season.find(1)
    headers['List-Unsubscribe'] = '<mailto:info@kuusipalaa.fi>'
    mail(to: @user.email, subject: @email.subject) do |format|
      format.html
      format.text
    end
  end

  def test_email(address, email, user, announcements, upcoming_events, future_events, open_time, new_proposals, still_needing_pledges, markdown)
    @email = email
    @user = user
    @is_email = true
    @emailannouncements = announcements
    @upcoming_events = upcoming_events
    @future_events = future_events
    @open_time = open_time
    @new_proposals = new_proposals
    @still_needing_pledges = still_needing_pledges
    @markdown = markdown
    @next_season = begin
      Season.find(2)
    rescue StandardError
      "2"
    end
    @current_season = Season.find(1)
    headers['List-Unsubscribe'] = '<mailto:info@kuusipalaa.fi>'
    mail(to: address, subject: @email.subject) do |format|
      format.html
      format.text
    end
  end
end
