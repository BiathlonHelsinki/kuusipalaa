namespace :kuusipalaa do
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
