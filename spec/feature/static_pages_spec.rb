require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before {
      visit root_path
      save_snapshot(example,"start")
    }

    it "should have h1 element with text Sample App" do
       should have_selector('h1',    text: 'Sample App')
    end

    it "should have default title", :js => true do
      should have_title(full_title(''))
    end

    it "should fail for demonstration", :js => true do
      should have_title(full_title('abc'))
    end

    describe "title" do
      it "should not have default title for Home" do
        should_not have_title('| Home')
      end
    end
  end

  describe "Help page" do
     before { visit help_path }

     it { should have_selector('h1',    text: 'Help') }
     it { should have_title(full_title('Help')) }
  end

  describe "About page" do
     before { visit about_path }

     it { should have_selector('h1',    text: 'About') }
     it { should have_title(full_title('About Us')) }
  end

  describe "Contact page" do
     before { visit contact_path }

     it { should have_selector('h1',    text: 'Contact') }
     it { should have_title(full_title('Contact')) }
  end
end