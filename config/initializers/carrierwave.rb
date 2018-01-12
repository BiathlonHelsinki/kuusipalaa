CarrierWave.configure do |config|
    config.storage = :aws
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.ignore_download_errors = false
    config.aws_credentials = {
      :access_key_id      => ENV.fetch('amazon_access_key'),
      :secret_access_key  => ENV.fetch('amazon_secret'),
      region: 'eu-central-1'
    }
    config.asset_host = "https://biathlon-#{Rails.env}.s3.eu-central-1.amazonaws.com"
    config.aws_acl    = 'public-read'

    config.aws_bucket  = "biathlon-#{Rails.env}"


  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end


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
