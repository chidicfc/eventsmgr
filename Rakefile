require "rubygems"
require "awesome_print"
require "require_all"



require_all "app"


desc 'create the required tables'
task :create do

  DB.create_table? :event_templates do
    primary_key :id
    String :title
    String :duration
    String :description
    String :status
  end

  DB.create_table? :events do
    primary_key :id
    foreign_key :event_template_id
    String :title
    String :duration
    String :description
    String :date
    String :start_time
    String :timezone
    String :cohort

  end

  DB.create_table? :coaches do
    primary_key :id
    String :name
    String :email
  end

  DB.create_table? :assigned_coaches do
    primary_key :id
    foreign_key :event_id
    String :name
  end

  DB.create_table? :coach_fees do
    primary_key :id
    foreign_key :event_template_id
    foreign_key :event_id
    String :currency
    String :amount
  end

  DB.create_table? :timezones do
    primary_key :id
    String :name
  end

  DB.create_table? :cohorts do
    primary_key :id
    String :name
  end

end

###################################################
desc 'seed data into the tables'
task :seed do
  datastore = DataBaseDataStore.new
  datastore.load_database
end
###################################################
desc 'show the tables'
task :show do
  puts "Event_templates"
  puts DB[:event_templates].all.inspect
  puts
  puts "Events"
  puts DB[:events].all.inspect
  puts
  puts "Coaches"
  puts DB[:coaches].all.inspect
  puts
  puts "Assigned Coaches"
  puts DB[:assigned_coaches].all.inspect
  puts
  puts "Coach Fees"
  puts DB[:coach_fees].all.inspect
  puts
  puts "Timezones"
  puts DB[:timezones].all.inspect
  puts
  puts "Cohorts"
  puts DB[:cohorts].all.inspect
end
####################################################
desc 'drops all tables'
task :clear do
  DB.run("DROP TABLE event_templates")
  DB.run("DROP TABLE events")
  DB.run("DROP TABLE coaches")
  DB.run("DROP TABLE assigned_coaches")
  DB.run("DROP TABLE coach_fees")
  DB.run("DROP TABLE timezones")
  DB.run("DROP TABLE cohorts")
end
######################################################
desc 'creates all the tables and calls seed'
task :migrate => :seed do
  puts "Migration completed"
end


desc 'console'
task :console do
  require "pry"
  require "./web"
  binding.pry
end




task :migrate => :create
