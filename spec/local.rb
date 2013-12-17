require File.expand_path("../../config/environment", __FILE__)
require 'capybara/rails'

puts "loading local.rb"

# Capybara local run
Capybara.javascript_driver = :selenium
Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end