# require 'simplecov'
# SimpleCov.start
require "capybara"
# require "wrong"
require "riot"
require 'pry'
require 'require_all'



Capybara.configure do |config|
  config.run_server = false

  Capybara.app_host = 'http://eventsmgr.dev'
end

if ENV['HEADLESS']=="yes"
  require 'capybara/poltergeist'
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  puts "run headlessly!"
else
  Capybara.default_driver = :selenium
  puts "run in browser"
end



require_all "app"

class User
  include  Capybara::DSL
end

class DataBase
  attr_reader :user
  def initialize user
    @user = user
    @datastore = DataBaseDataStore.new
  end

  def clear
    DB.run("DROP TABLE event_templates")
    DB.run("DROP TABLE events")
    DB.run("DROP TABLE coaches")
    DB.run("DROP TABLE assigned_coaches")
    DB.run("DROP TABLE coach_fees")
    DB.run("DROP TABLE timezones")
    DB.run("DROP TABLE cohorts")
  end

  def create
    clear

    user.visit "/"
    user.click_button "New Event Template"

    user.fill_in 'Title', with: "Premium Coaching"
    user.fill_in 'Duration', with: "08:30"

    user.fill_in "GBP", with: "10.00"
    user.fill_in "USD", with: "20.00"
    user.fill_in "EUR", with: "30.00"
    user.fill_in "AUD", with: "40.00"
    user.fill_in "SGD", with: "50.00"

    user.fill_in "Description", with: "Premium coaching's description"
    user.click_button "Create Template"

  end

  def create_inactive_event
    create
    user.page.find_by_id(11).click_button("Create New Event")
    user.fill_in 'sub_title', with: "Argos"
    user.fill_in 'Date', with: "2013-04-12"

    user.select "Delaney Burke 1", :from => "coaches_list"
    user.select "Tom Green 1", :from => "coaches_list"
    user.click_button "Add"

    user.click_button "Create Event"

  end

  def create_active_event
    create
    user.page.find_by_id(11).click_button("Create New Event")
    user.fill_in 'sub_title', with: "Argos"
    user.fill_in 'Date', with: "2016-09-12"

    user.select "Delaney Burke 1", :from => "coaches_list"
    user.select "Tom Green 1", :from => "coaches_list"
    user.click_button "Add"

    user.click_button "Create Event"

  end



end


context "Events_Manager" do
  helper(:user){User.new}

  context "Event_Template" do
    helper(:edit) do
      DataBase.new(user).create
      user.page.find_by_id(11).click_button("Edit")

      user.fill_in 'Title', with: "Premium Coaching Changed"
      user.fill_in 'Duration', with: "09:40"
      user.fill_in "GBP", with: "60.00"
      user.fill_in "USD", with: "70.00"
      user.fill_in "EUR", with: "80.00"
      user.fill_in "AUD", with: "90.00"
      user.fill_in "SGD", with: "100.00"
      user.fill_in "Description", with: "Premium coaching's new description"
      user.click_button "Edit Template"
      #when
      user.page.find_by_id(11).click_button("Edit")

    end

    helper(:archive) do
      database = DataBase.new(user)
      database.create

      user.within("div[id='11']") do
        if user.page.first("span").text.include? "0,"
          user.first(:button, "Archive").click
        end
      end
    end

    asserts ("can create") do
      DataBase.new(user).clear
      user.visit "/"
      user.click_button "New Event Template"

      user.fill_in 'Title', with: "Premium Coaching"
      user.fill_in 'Duration', with: "08:30"

      user.fill_in "GBP", with: "10.00"
      user.fill_in "USD", with: "20.00"
      user.fill_in "EUR", with: "30.00"
      user.fill_in "AUD", with: "40.00"
      user.fill_in "SGD", with: "50.00"

      user.fill_in "Description", with: "Premium coaching's description"
      #when
      user.click_button "Create Template"
      #then
      user.page.has_content? "Premium Coaching"

    end

    asserts ("can edit title") do
      edit
      #then
      user.page.has_content? "Premium Coaching Changed"
    end

    asserts ("can edit duration") do
      edit
      user.find_field("duration").value == "09:40"
    end

    asserts ("can edit default coach_fee") do
      edit
      user.find_field("amount0").value == "60.00"
      user.find_field("amount1").value ==  "70.00"
      user.find_field("amount2").value ==  "80.00"
      user.find_field("amount3").value ==  "90.00"
      user.find_field("amount4").value ==  "100.00"
    end

    asserts ("can edit description") do
      edit
      user.find_field("description").value == "Premium coaching's new description"
    end

    asserts ("can delete: contains no event") do
      DataBase.new(user).create
      user.within("div[id='11']") do
        user.first(:button, "Delete").click if user.page.first("span").text.include? "0,"
      end
      !user.page.has_content?("Premium Coaching")
    end

    asserts ("can't delete: has event") do
      DataBase.new(user).create
      user.within("div[id='10']") do
        user.first(:button, "Delete").click
      end
      user.page.has_content?("Boots Coaching Capability 10")
    end

    asserts ("can archive: contains no event") do
      database = DataBase.new(user)
      database.create

      user.within("div[id='11']") do
        if user.page.first("span").text.include? "0,"
          user.first(:button, "Archive").click
        end
      end
      !user.page.has_content?("Premium Coaching")
    end

    asserts ("can archive: contains inactive event") do
      database = DataBase.new(user)
      database.create_inactive_event
      user.visit '/'
      user.within("div[id='11']") do
        user.first(:button, "Archive").click
      end
      !user.page.has_content?("Premium Coaching")
    end

    asserts ("can't archive: contains active event") do
      database = DataBase.new(user)
      database.create_active_event
      user.visit '/'
      user.within("div[id='11']") do
        user.first(:button, "Archive").click
      end
      user.page.has_content?("Premium Coaching")
    end

    asserts ("can show archive") do
      archive
      user.click_button "Show Archive"
      user.page.has_content?("Premium Coaching")
    end

      asserts ("can show event templates") do
        DataBase.new(user).create
        user.visit '/show_archive'
        user.click_button "Show Event Templates"
        user.page.has_content?("Premium Coaching")
      end

    asserts ("can unarchive") do
      archive
      user.click_button "Show Archive"
      user.page.find_by_id(11).first(:button, "Unarchive").click
      user.visit '/show_archive'
      !user.page.has_content?("Premium Coaching")
    end

    asserts ("can search templates by letter") do
      DataBase.new(user).create
      user.page.find_by_id("search").find_by_id("A").click
      !user.page.has_content?("A*")
    end

    asserts ("can search templates by word") do
      DataBase.new(user).create
      user.find_by_id("form_id").fill_in "search", with: "Premium"
      user.find_by_id("form_id").click_button "GO"
      !user.page.has_content?("Boots*")
    end

    asserts ("can search archive templates by letter") do
      archive
      user.click_button "Show Archive"
      user.page.find_by_id("search").find_by_id("P").click
      user.page.has_content?("Premium Coaching")
    end

    asserts ("can search archive templates by word") do
      archive
      user.find_by_id("form_id").fill_in "search", with: "Boots"
      user.find_by_id("form_id").click_button "GO"
      !user.page.has_content?("Premium Coaching")
    end

  end

  context "Event" do
    helper(:create) do
      database = DataBase.new(user)
      database.create

      user.within("div[id='11']") do
        user.first(:button, "Create New Event").click
      end

      user.fill_in 'sub_title', with: "Argos"
      user.select "Delaney Burke 1", :from => "coaches_list"
      user.select "Tom Green 1", :from => "coaches_list"
      user.click_button "Add"

      user.click_button "Create Event"

    end

    helper(:edit_event) do
      create
      user.page.find_by_id(11).find_by_id("events").first(:button, "Edit").click
      user.fill_in 'sub_title', with: "Microsoft"
      user.fill_in 'Date', with: "2014-10-12"
      user.fill_in 'description', with: "microsoft description"

      user.select "10", :from => "start_hours"
      user.select "30", :from => "start_mins"

      user.select "1", :from => "duration_hours"
      user.select "30", :from => "duration_mins"

      user.select "(GMT+10.00) + Sydney", :from => "timezone"
      user.select "Apple North America Cohort B", :from => "cohort"

      user.fill_in 'GBP', with: "60"
      user.fill_in 'USD', with: "70"
      user.fill_in 'EUR', with: "80"
      user.fill_in 'AUD', with: "90"
      user.fill_in 'SGD', with: "100"

      user.select "Delaney Burke 1", :from => "coaches_list"
      user.select "Tom Green 1", :from => "coaches_list"

      user.click_button "Add"

      user.click_button "Edit Event"
    end

    asserts ("can create") do
      create
      user.page.has_content?("Argos")
    end

    asserts ("can edit subtitle") do
      edit_event
      user.page.find_by_id(11).find_by_id("events").first(:button, "Edit").click
      user.find_field("sub_title").value == "Microsoft"
    end

    asserts ("can edit date") do
      edit_event
      user.page.find_by_id(11).find_by_id("events").first(:button, "Edit").click
      user.find_field("date").value == "2014-10-12"
    end

    asserts ("can edit description") do
      edit_event
      user.page.find_by_id(11).find_by_id("events").first(:button, "Edit").click
      user.find_field("description").value == "microsoft description"
    end

    asserts ("can delete: has no assigned coach") do
      database = DataBase.new(user)
      database.create

      user.within("div[id='11']") do
        user.first(:button, "Create New Event").click
      end

      user.fill_in 'sub_title', with: "Argos new"

      user.click_button "Create Event"

      user.page.find_by_id(11).find_by_id("events").first(:button, "Delete").click

      !user.page.has_content?("Argos new")

    end

    asserts ("can't delete: has assigned coach(es)") do
      database = DataBase.new(user)
      database.create_active_event
      user.visit '/'

      user.page.find_by_id(11).find_by_id("events").first(:button, "Delete").click
      user.page.has_content?("Argos")
    end

  end

end
