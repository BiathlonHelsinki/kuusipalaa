class Admin::EmailsController < Admin::BaseController
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  
  def create
    @email = Email.new(email_params)
    if @email.save!
      flash[:notice] = 'Email draft saved.'
      redirect_to admin_emails_path
    end
  end
  
  def destroy
    @email = Email.friendly.find(params[:id])
    if @email.sent == true
      flash[:error] = 'You cannot delete an email announcement after it has been sent.'

    else
      @email.destroy
      flash[:notice] = 'Email announcement deleted.'
    end
    redirect_to admin_emails_path
  end
  
  def edit
    @email = Email.friendly.find(params[:id])
  end
  
  def new
    @email = Email.new
  end
  
  def index
    @emails = Email.all.order(:sent_at)
  end
  
  
  def send_test
    @email = Email.friendly.find(params[:id])
    recipient = params[:email_address]
    body = ERB.new(@email.body).result(binding).html_safe
    EmailsMailer.test(recipient, @email, body).deliver_now
    
    flash[:notice] = 'Email sent to ' + recipient
    redirect_to admin_emails_path
  end
  
  def send_test_address
    @email = Email.friendly.find(params[:id])
    # @user = User.find(1)
    @user =  current_user
    @upcoming_events = Instance.calendered.published.between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    @open_time = Instance.where(open_time: true).between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    # @body = ERB.new(@email.body).result(binding).html_safe
    @new_proposals = Idea.active.unconverted.where(["created_at >= ? ", @email.send_at - 1.week])
    @still_needing_pledges = Idea.active.unconverted.except(@new_proposals).reject(&:has_enough?)
    if @user.is_stakeholder?
      @emailannouncements = @email.emailannouncements
    else
      @emailannouncements = @email.emailannouncements.reject(&:only_stakeholders)
    end
  
    @future_events = Instance.calendered.published.between((@email.send_at + 1.week).end_of_day, '2099-01-31 10:00:00')
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    set_meta_tags title: @email.subject
    @is_email = true

    # body = ERB.new(@email.body).result(binding).html_safe
    EmailsMailer.test_email(params[:email_address], @email, @user, @emailannouncements, @upcoming_events, @future_events, @open_time, @new_proposals, @still_needing_pledges, @markdown).deliver_now
    
    flash[:notice] = 'Email sent to ' + @user.email
    redirect_to admin_emails_path
  end
  
  def send_to_list
    @email = Email.friendly.find(params[:id])
    if @email.sent == true
      flash[:notice] = 'Email already sent'
      redirect_to admin_emails_path
    else
      @upcoming_events = Instance.calendered.published.between(@email.send_at, (@email.send_at + 1.week).end_of_day)
      @open_time = Instance.where(open_time: true).between(@email.send_at, (@email.send_at + 1.week).end_of_day)
      @new_proposals = Idea.active.unconverted.where(["created_at >= ? ", @email.send_at - 1.week])
      @still_needing_pledges = Idea.active.unconverted.except(@new_proposals).reject(&:has_enough?)
      @future_events = Instance.calendered.published.between((@email.send_at + 1.week).end_of_day, '2099-01-31 10:00:00')
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      set_meta_tags title: @email.subject
      @is_email = true
      mailing_list = User.where(opt_in: true).where("email not like 'change@me%'")
      if Rails.env.development?
        mailing_list[3..7].each do |recipient|
          @user = recipient
          if @user.is_stakeholder?
            @emailannouncements = @email.emailannouncements
          else
            @emailannouncements = @email.emailannouncements.reject(&:only_stakeholders)
          end
          EmailsMailer.announcement(recipient, @email, @user, @emailannouncements, @upcoming_events, @future_events, @open_time, @new_proposals, @still_needing_pledges, @markdown).deliver_now
        end
      else
        mailing_list.each do |recipient|
          @user = recipient
          if @user.is_stakeholder?
            @emailannouncements = @email.emailannouncements
          else
            @emailannouncements = @email.emailannouncements.reject(&:only_stakeholders)
          end
          EmailsMailer.announcement(recipient, @email, @user, @emailannouncements, @upcoming_events, @future_events, @open_time, @new_proposals, @still_needing_pledges, @markdown).deliver_later
        end
        @email.sent = true

        newemail = Email.create(send_at: @email.send_at + 1.week, body: 'test', subject: 'This week at Kuusi Palaa - ' + (@email.send_at + 1.week).strftime('%d %B %Y'))
        @email.save
      end
      flash[:notice] = 'Sending emails to ' + mailing_list.size.to_s + " users"
      @email.sent_number = mailing_list.size
      @email.sent_at = Time.current
     
      newemail = Email.create(send_at: @email.send_at + 1.week, body: 'test', subject: 'This week at Kuusi Palaa - ' + (@email.send_at + 1.week).strftime('%d %B %Y'))
      @email.save
      redirect_to admin_emails_path
    end
  end
  
  def update
    @email = Email.friendly.find(params[:id])
    if @email.update_attributes(email_params)
      flash[:notice] = 'Email draft updated.'
      redirect_to admin_emails_path
    end
  end
  
  private
  
  def email_params
    params.require(:email).permit(:subject, :body)
  end
  
end