puts "loading support/remote.rb"

#require File.expand_path("../../config/environment", __FILE__)
require_relative 'config'
require 'rspec/rails'
require 'capybara/rails'

def set_app_address()
  require 'system/getifaddrs'
  ip = $webserver_ip != nil ? $webserver_ip : System.get_ifaddrs.find{ |socket| socket[1][:inet_addr] != "127.0.0.1" } [1][:inet_addr]
  port = $webserver_port != nil ? $webserver_port : Capybara.current_session.server.port
  Capybara.app_host = "http://#{ip}:#{port}"
  #puts "Registering http://#{ip}:#{port} as root server"
end

Capybara.javascript_driver = :selenium
Capybara.default_driver = :selenium

# Capybara remote run
# # init ip
caps = Selenium::WebDriver::Remote::Capabilities.chrome
# caps.version = "8"
caps.platform = :WINDOWS

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
      app,
      :browser => :remote,
      :url => "http://#{$grid_host}:#{$grid_port}/wd/hub",
      :desired_capabilities => caps
  )
end

Before do |scenario|
  set_app_address()
end



