source 'https://rubygems.org'

gem 'rake', '10.1.0'
gem 'rails', '3.2.14'
gem 'bootstrap-sass', '2.1'

gem 'bcrypt-ruby', '3.0.1'

gem 'therubyracer'


group :development, :test do
  gem "system-getifaddrs", "~> 0.2.0"
  gem 'sqlite3', '1.3.5'

  gem 'rspec-rails', '~> 2.0'
  # add to Gemfile
  gem "parallel_tests"
  gem 'selenium-webdriver'

  gem 'poltergeist'
  
  gem 'cucumber-rails', :require => false

  gem 'ci_reporter'
end

group :development do
  gem 'annotate', '2.5.0'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.2.5'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '1.2.3'
end

gem 'jquery-rails', '2.0.2'

group :test do
  gem "capybara", "~> 2.1.0"
  gem 'database_cleaner'
end

group :production do
  gem 'pg', '0.12.2'
end