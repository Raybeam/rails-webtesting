puts "loading support/remote.rb"

require File.expand_path("../../config/environment", __FILE__)
require 'capybara/rails'
require 'system/getifaddrs'

Capybara.javascript_driver = :selenium
Capybara.default_driver = :rack_test


# Capybara remote run
# # init ip
caps = Selenium::WebDriver::Remote::Capabilities.chrome
# caps.version = "8"
caps.platform = :WINDOWS
host = "10.242.1.187"
port = "4444"
ip = System.get_ifaddrs.find{ |socket| socket[1][:inet_addr] != "127.0.0.1" } [1][:inet_addr]

Capybara.server_port = 3010
Capybara.app_host = "http://#{ip}:#{Capybara.server_port}"
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
    app,
    :browser => :remote,
    :url => "http://#{host}:#{port}/wd/hub",
    :desired_capabilities => caps
    )
end

# RSpec.configure do |config|
# 	config.after(:each) do
# 		puts Capybara.app_host
# 		puts Capybara.server_port
# 		puts Capybara.current_session.server
# 	end
# end


