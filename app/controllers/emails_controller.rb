class EmailsController < ApplicationController
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  caches_page :this_week, :next_week
  #before_action :authenticate_stakeholder!, only: [:next_week]

  def next_week
    prepare_email
    @is_email = false
    render(template: 'emails/show')
  end

  def this_week
    @email = Email.sent.where.not(send_at: nil).order(send_at: :asc).last
    @is_email = false
    @user = current_user
    @upcoming_events = Instance.calendered.published.between(@email.send_at, (@email.send_at + 1.week).end_of_day).group_by { |x| [x.event_id, x.sequence] }
    @open_time = Instance.where(open_time: true).between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    @body = ERB.new(@email.body).result(binding).html_safe
    @new_proposals = Idea.active.unconverted.where(["created_at >= ? ", @email.send_at - 1.week])
    @still_needing_pledges = Idea.active.unconverted.except(@new_proposals).reject(&:has_enough?).reject { |x| @new_proposals.include?(x) }
    @emailannouncements = if user_signed_in?
      if current_user.is_stakeholder?
        @email.emailannouncements
      else
        @email.emailannouncements.reject(&:only_stakeholders)
      end
    else
      @email.emailannouncements.reject(&:only_stakeholders)
    end
    @future_events = Instance.calendered.published.between((@email.send_at + 1.week).end_of_day, '2099-01-31 10:00:00').group_by { |x| [x.event_id, x.sequence] }.to_a.delete_if { |x| @upcoming_events.map(&:first).include?(x.first) }
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    set_meta_tags(title: @email.subject)
    render(template: 'emails/show')
  end

  def show
    @user = current_user if user_signed_in?
    prepare_email
    @is_email = false
    set_meta_tags(title: @email.subject)
  end

  private

  def prepare_email
    @email = if params[:id]
      Email.friendly.find(params[:id])
    else
      Email.unsent.order(send_at: :asc).last
    end
    @user = current_user
    @upcoming_events = Instance.calendered.published.between(@email.send_at, (@email.send_at + 1.week).end_of_day).group_by { |x| [x.event_id, x.sequence] }
    @open_time = Instance.where(open_time: true).between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    @body = ERB.new(@email.body).result(binding).html_safe
    @new_proposals = Idea.active.unconverted.where(["created_at >= ? ", @email.send_at - 1.week])
    @still_needing_pledges = Idea.active.unconverted.except(@new_proposals).reject(&:has_enough?).reject { |x| @new_proposals.include?(x) }
    @emailannouncements = if user_signed_in?
      if current_user.is_stakeholder?
        @email.emailannouncements
      else
        @email.emailannouncements.reject(&:only_stakeholders)
      end
    else
      @email.emailannouncements.reject(&:only_stakeholders)
    end
    @future_events = Instance.calendered.published.between((@email.send_at + 1.week).end_of_day, '2099-01-31 10:00:00').group_by { |x| [x.event_id, x.sequence] }.to_a.delete_if { |x| @upcoming_events.map(&:first).include?(x.first) }
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    set_meta_tags(title: @email.subject)
  end
end
