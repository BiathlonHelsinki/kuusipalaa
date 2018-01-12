# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base

  storage :aws

  def store_dir
    "attachments/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end


end
