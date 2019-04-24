
source 'https://rubygems.org'

ruby '2.6.2'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
if defined?(RUBY_DESCRIPTION) && RUBY_DESCRIPTION.start_with?("ruby 2.4")
  gem "openssl"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.3'
# Use sqlite3 as the database for Active Record
gem 'pg', '0.21.0'
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
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem "database_cleaner"
  gem "rspec-rails", '~> 3.5'
end

group :test do
  gem 'factory_bot_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'simplecov', require: false
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


end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'best_in_place', '~> 3.0.1'

gem 'capistrano'
gem 'capistrano-rails'#, '1.1.3'
gem 'capistrano-rvm'
gem 'capistrano-bundler'#, '1.1.4'
gem 'capistrano3-puma'

gem 'activerecord-session_store'
gem "audited", "~> 4.5"
gem 'auto_html'
gem 'awesome_nested_set'
gem 'cancancan'
gem 'carrierwave'
gem 'carrierwave_backgrounder', :git => 'https://github.com/lardawge/carrierwave_backgrounder.git'
gem 'carrierwave-aws'

gem 'chosen-rails'
gem 'ckeditor'
gem 'cookies_eu'
gem 'country_select'
gem 'delayed_job_active_record'
gem 'devise'
gem 'error_page_assets'
gem 'figaro'
gem 'fittextjs_rails'
gem 'font-awesome-rails'
gem 'friendly_id', '~> 5.2.4'
gem 'fullcalendar-rails'
gem 'geocoder'
gem 'globalize' , '~> 5.2.0' #, git: 'https://github.com/globalize/globalize'
gem 'activemodel-serializers-xml'
gem 'has_scope'
gem 'httparty'
gem 'http_accept_language'
gem 'httmultiparty'
gem 'icalendar'
gem "jquery-slick-rails"
gem 'kaminari'
gem 'magnific-popup-rails', '~> 1.1.0'
gem 'mailgun_rails'
gem 'meta-tags'
gem 'migration_data'
gem 'mimemagic'
gem 'mini_magick'
gem 'momentjs-rails'
gem 'multipart-post'
gem 'nested_form'
gem 'net-ping'
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
gem 'redcarpet'
gem 'rolify'
gem 'rollbar'
gem 'simple_token_authentication', git: 'https://github.com/gonzalo-bulnes/simple_token_authentication.git', branch: 'master'
gem 'stripe'
gem 'truncate_html'
gem 'valvat'
gem 'viitenumero', github: 'bittisiirto/viitenumero', branch: :master
gem 'wicked'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
