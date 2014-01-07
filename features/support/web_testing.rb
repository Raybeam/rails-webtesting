require 'capybara/cucumber'
require 'capybara/poltergeist'
require_relative 'config'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.default_driver = :selenium

FileUtils.rm_rf($base_report_dir)
FileUtils.mkdir($base_report_dir)

After do |scenario|
  # if(scenario.failed?)
    img_name = "#{scenario.__id__}.png"
    path_to_img = File.join($base_report_dir,img_name)
    page.save_screenshot(path_to_img)
    embed(img_name, "image/png", "SCREENSHOT")
  # end
end