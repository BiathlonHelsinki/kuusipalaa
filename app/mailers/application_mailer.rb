class ApplicationMailer < ActionMailer::Base
  default from:  "info@kuusipalaa.fi"
  default "Message-ID" => lambda {"<#{SecureRandom.uuid}@kuusipalaa.fi>"}
  layout 'mailer'
end
