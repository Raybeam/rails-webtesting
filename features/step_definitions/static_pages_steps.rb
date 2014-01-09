Given(/^I am a guest$/) do

end

When(/^I go to (.+)$/) do |path_name|
  page.visit path_to(path_name)
end

When(/^I visit (.+)$/) do |path_name|
  page.visit(path_name)
end

Then(/^title is default title\.$/) do
  page.should have_title(full_title(''))
end

When (/^click on (.+)$/) do |item|
  if item == "link to sign up"
    page.find(:xpath, "//a[@id='signup']").click
  end
end

Then (/^"(.*)" is visible$/) do |text|
  page.should have_content(text)
end