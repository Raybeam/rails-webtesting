require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require_relative 'support/config'

puts "loading fail_fast.rb"

RSpec.configure do |config|
  config.fail_fast = true

  config.after(:each) do
    if example.exception
      # stub in browser close method
      Selenium::WebDriver::Driver.class_eval do
        def quit
          puts "preventing browser close"
          #STDOUT.puts "#{self.class}#quit: no-op"
        end
      end

      # stub in driver close method
      Selenium::WebDriver::Chrome::Service.class_eval do
        def stop
          puts "preventing ChromeDriver stop"
          #STDOUT.puts "#{self.class}#stop: no-op"
        end
      end
      
      # stub in Capybara's reset which to resets browser to about page
      Capybara::Selenium::Driver.class_eval do
        def reset!
          puts "preventing reset to about page"
        end
      end
    end
  end
end