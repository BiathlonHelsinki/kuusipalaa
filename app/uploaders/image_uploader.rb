# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay
  include CarrierWave::MiniMagick

  storage :aws


  def default_url
    "/icons/#{model.class.to_s.downcase}_missing.png"
  end

  def store_dir
    "images/#{model.class.table_name.singularize.underscore}/#{mounted_as}/#{model.id}"
  end

  version :wide do
    process :auto_orient
    process :resize_to_fill => [1200, 500]
  end

  version :twelvehundred do
    process :auto_orient
    process :resize_to_fit => [1200, 900]
  end

  version :medium, from: :twelvehundred do
    process :auto_orient
    process :resize_to_fit => [800, 600]
  end

  version :small, from: :medium do
    process :auto_orient
    process :resize_to_fit => [300, 300]
  end

  version :box do
    process :auto_orient
    process :resize_to_fill => [400, 400]
  end

  version :thumb, from: :box do
    process :auto_orient
    process :resize_to_fill => [100, 100]
  end

  def auto_orient
    manipulate! do |img|
      img = img.auto_orient
    end
  end



end
