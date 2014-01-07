Given(/^I am a guest$/) do

end

When(/^I go to (.+)$/) do |path_name|
  page.visit path_to(path_name)
end

Then(/^title is default title\.$/) do
  page.should have_title(full_title(''))
end