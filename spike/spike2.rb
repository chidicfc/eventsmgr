require "./app/db"
require "rubygems"
require "pry"
require "awesome_print"


puts "EVENT TEMPLATES"
p DB[:event_templates].all
puts
puts "EVENTS"
ap DB[:events].all
puts
puts "ASSIGNED_COACHES"
p DB[:assigned_coaches].all
puts
puts "COACH_FEES"
p DB[:coach_fees].all
puts
puts "COACHES"
p DB[:coaches].all
puts
puts "TIMEZONES"
p DB[:timezones].all
puts
puts "COHORTS"
p DB[:cohorts].all
