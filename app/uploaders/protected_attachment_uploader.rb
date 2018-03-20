# encoding: utf-8

class ProtectedAttachmentUploader < CarrierWave::Uploader::Base
  storage :aws
  configure do |config|
    config.aws_bucket  = "biathlon-private"
    config.aws_acl = 'private'
  end
  def store_dir
    "#{Rails.env}/attachments/protected/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end


  def fog_public
    false
  end

  def fog_authenticated_url_expiration
    1.minutes # in seconds from now,  (default is 10.minutes)
  end
end
