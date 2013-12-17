require File.expand_path("../../config/environment", __FILE__)
require 'capybara/rails'

require 'capybara/poltergeist'
# Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist