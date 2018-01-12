source 'https://rubygems.org'

ruby '2.4.2'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'formtastic'
gem 'foundation-rails', "6.3.1.0"
gem 'foundation-datetimepicker-rails', '0.2.4'
gem 'haml'
gem "haml-rails"#, "~> 0.9"
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'better_errors' #, github: 'workingnotworking/better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'ruby_parser', '>= 3.0.1'
  gem 'thin'
  gem 'pry-rails' # use pry when running `rails console`
  gem 'pry-byebug'

end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'capistrano'
gem 'capistrano-rails'#, '1.1.3'
gem 'capistrano-rvm'
gem 'capistrano-bundler'#, '1.1.4'
gem 'capistrano3-puma'


gem "audited", "~> 4.5"
gem 'auto_html'
gem 'awesome_nested_set'
gem 'cancancan'
gem 'carrierwave'
gem 'carrierwave_backgrounder', :git => 'https://github.com/lardawge/carrierwave_backgrounder.git'
gem 'carrierwave-aws'

gem 'chosen-rails'
gem 'ckeditor', github: 'galetahub/ckeditor'
gem 'country_select'
gem 'delayed_job_active_record'
gem 'devise'

gem 'figaro'
gem 'font-awesome-rails'
gem 'friendly_id', '~> 5.1.0'
gem 'geocoder'
gem 'globalize', git: 'https://github.com/globalize/globalize'
gem 'activemodel-serializers-xml'
gem 'has_scope'
gem 'httparty'
gem 'http_accept_language'
gem 'httmultiparty'
gem 'icalendar'
gem 'kaminari'
gem 'meta-tags'
gem 'migration_data'
gem 'mimemagic'
gem 'mini_magick'
gem 'multipart-post'
gem 'nested_form'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem "omniauth-google-oauth2"
gem "paranoia", '~> 2.4.0'
gem 'pg_search'
gem 'rack-utf8_sanitizer'
gem 'rails-jquery-autocomplete'
gem "recaptcha", require: "recaptcha/rails"
gem 'rolify'
gem 'simple_token_authentication', git: 'https://github.com/gonzalo-bulnes/simple_token_authentication.git', branch: 'master'
gem 'truncate_html'
