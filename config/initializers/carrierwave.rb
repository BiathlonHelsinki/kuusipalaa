CarrierWave.configure do |config|
    config.storage = :aws
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.ignore_download_errors = false
    config.aws_credentials = {
      :access_key_id      => ENV.fetch('wasabi_access_key'),
      :secret_access_key  => ENV.fetch('wasabi_secret'),
      region: 'us-east-1'
    }
    # config.asset_host = Rails.env.development? ? "https://biathlon-#{Rails.env}.s3.eu-central-1.amazonaws.com" : "https://media.kuusipalaa.fi"
    config.asset_host =  "https://biathlon-#{Rails.env}.s3.wasabisys.com"
    config.aws_acl    = 'public-read'

    config.aws_bucket  = "biathlon-#{Rails.env}"


  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
Aws.config.update({endpoint: 'https://s3.wasabisys.com'})

# CarrierWave.configure do |config|
#   config.fog_provider = 'fog/aws'                        # required
#   config.fog_credentials = {
#     provider:              'AWS',                        # required
#     aws_access_key_id:     ENV.fetch('amazon_access_key'),                        # required
#     aws_secret_access_key: ENV.fetch('amazon_secret'),                        # required
#     region:                'eu-central-1'                  # optional, defaults to 'us-east-1'
#
#
#   }
#   config.fog_directory  = 'biathlon-development'                          # required
#   config.fog_attributes = { cache_control: "public, max-age=#{365.day.to_i}" } # optional, defaults to {}
# end
