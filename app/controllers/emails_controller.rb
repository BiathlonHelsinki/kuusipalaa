class EmailsController < ApplicationController
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  #before_action :authenticate_stakeholder!, only: [:next_week]

  def next_week
    prepare_email
    @is_email = false
    render template: 'emails/show'
  end

  def this_week
    @email = Email.sent.where("send_at is not null").order(send_at: :asc).last
    @is_email = false
    @user = current_user
    @upcoming_events = Instance.calendered.published.between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    @open_time = Instance.where(open_time: true).between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    @body = ERB.new(@email.body).result(binding).html_safe
    @new_proposals = Idea.active.unconverted.where(["created_at >= ? ", @email.send_at - 1.week])
    @still_needing_pledges = Idea.active.unconverted.except(@new_proposals).reject(&:has_enough?).reject{|x| !@new_proposals.include?(x) }
    if user_signed_in?
      if current_user.is_stakeholder?
        @emailannouncements = @email.emailannouncements
      else
        @emailannouncements = @email.emailannouncements.reject(&:only_stakeholders)
      end
    else
      @emailannouncements = @email.emailannouncements.reject(&:only_stakeholders)
    end
    @future_events = Instance.calendered.published.between((@email.send_at + 1.week).end_of_day, '2099-01-31 10:00:00')
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    set_meta_tags title: @email.subject
    render template: 'emails/show'
  end

  def show

    if user_signed_in?
      @user = current_user
    end
    prepare_email
    @is_email = false
    set_meta_tags title: @email.subject
  end
  
  private
    def prepare_email
      if params[:id]
        @email = Email.friendly.find(params[:id])
      else
        @email = Email.unsent.order(send_at: :asc).last
      end
      @user = current_user
      @upcoming_events = Instance.calendered.published.between(@email.send_at, (@email.send_at + 1.week).end_of_day)
      @open_time = Instance.where(open_time: true).between(@email.send_at, (@email.send_at + 1.week).end_of_day)
      @body = ERB.new(@email.body).result(binding).html_safe
      @new_proposals = Idea.active.unconverted.where(["created_at >= ? ", @email.send_at - 1.week])
      @still_needing_pledges = Idea.active.unconverted.except(@new_proposals).reject(&:has_enough?)
      if user_signed_in?
        if current_user.is_stakeholder?
          @emailannouncements = @email.emailannouncements
        else
          @emailannouncements = @email.emailannouncements.reject(&:only_stakeholders)
        end
      else
        @emailannouncements = @email.emailannouncements.reject(&:only_stakeholders)
      end
      @future_events = Instance.calendered.published.between((@email.send_at + 1.week).end_of_day, '2099-01-31 10:00:00')
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      set_meta_tags title: @email.subject
    end
end