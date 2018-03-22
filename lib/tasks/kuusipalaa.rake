namespace :kuusipalaa do

  desc 'notify invoices unpaid after > 3 weeks'
  task late_invoices: :environment do
    Stake.really_late.each do |stake|
      StakeMailer.late_stake(stake).deliver_now
    end
  end

  desc 'send weekly email'
  task weekly_email: :environment  do
    @email = Email.unsent.order(send_at: :asc).last
    if @email['send_at'] > Time.current.localtime
      abort("needs to send at " + @email['send_at'].to_s + " but it is " + Time.current.localtime.to_s)
    end
    if @email.nil?
      abort("email not found")
    end
    @upcoming_events = Instance.calendered.published.between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    @open_time = Instance.where(open_time: true).between(@email.send_at, (@email.send_at + 1.week).end_of_day)
    @body = ERB.new(@email.body).result(binding).html_safe
    @new_proposals = Idea.active.unconverted.where(["created_at >= ? ", @email.send_at - 1.week])
    @still_needing_pledges = Idea.active.unconverted.except(@new_proposals).reject(&:has_enough?)
    @future_events = Instance.calendered.published.between((@email.send_at + 1.week).end_of_day, '2099-01-31 10:00:00')
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
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
      @email.sent = true
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

      # newemail = Email.create(send_at: @email.send_at + 1.week, body: 'test', subject: 'This week at Kuusi Palaa - ' + (@email.send_at + 1.week).strftime('%d %B %Y'))

    end

    @email.sent_number = mailing_list.size
    @email.sent_at = Time.current  
    newemail = Email.create(send_at: @email.send_at + 1.week, body: 'test', subject: 'This week at Kuusi Palaa - ' + (@email.send_at + 1.week).strftime('%d %B %Y'))
    @email.save
  end

  desc 'reset development environment from db dump'
  task reset_dev: :environment do
    s = Setting.first
    s.destroy!
    Setting.create(options: {"network" => Figaro.env.network, "contract_address" => Figaro.env.contract_address, 
          'coinbase' => Figaro.env.coinbase, 'node_abi' => Figaro.env.node_contract_abi, 'token_abi' => Figaro.env.token_contract_abi,
      'nodelist_address' => Figaro.env.nodelist_address, 'token_address' => Figaro.env.token_address,
      'latest_block' => 0})
    account = Account.find_by(user_id: 1)
    account.address = '0x71ee2c7fcdf0a25b14afd7d91536af63c862a8c6'
    account.external = false
    account.save!
    account = Account.find_by(user_id: 4)
    account.address = '0x33c0e71a072a38b6f0d72a23be979ed7a713bcdb'
    account.external = false
    account.save!    
  end

  desc 'load production biathlon info into db'
  task reset_prod: :environment do
    s = Setting.first
    s.destroy!
    Setting.create(options: {"network" => Figaro.env.network, "contract_address" => Figaro.env.contract_address, 
          'coinbase' => Figaro.env.coinbase, 'node_abi' => Figaro.env.node_contract_abi, 'token_abi' => Figaro.env.token_contract_abi,
      'nodelist_address' => Figaro.env.nodelist_address, 'token_address' => Figaro.env.token_address,
      'latest_block' => 0})   
  end
  
  desc 'get missing checkins back to activity field'
  task find_missing_activities: :environment do
    InstancesUser.all.order(:id).each do |iu|
      if iu.activity.nil?
        p "Check in of " + iu.user.display_name + " to #{iu.instance.name} is not in activity feed"
      end
    end
  end

  desc 'check door controller'
  task check_door_controller: :environment do
    require 'net/http'
    require 'uri'
    Hardware.monitored.each do |hardware|
      if hardware.last_checked_at.utc <= 90.minutes.ago
        next if hardware.notified_of_error == true
        uri = URI.parse("https://textbelt.com/text")
        numbers = Figaro.env.emergency_contact.split(',')
        numbers.each do |number|
          Net::HTTP.post_form(uri, {
            :phone => number,
            :message => "The Kuusi Palaa #{hardware.name} has not been online since #{hardware.last_checked_at.localtime.to_s}, please check!",
            :key => Figaro.env.textbelt_key
          })

          hardware.update_attribute(:notified_of_error, true)
          

        end
      end
        
    end
  end
  

end
