require "./app/db"
require "rubygems"
require "pry"
require "awesome_print"


puts "EVENT TEMPLATES"
ap DB[:event_templates].all
puts
puts "EVENTS"
ap DB[:events].all
puts
puts "ASSIGNED_COACHES"
ap DB[:assigned_coaches].all
puts
puts "COACH_FEES"
ap DB[:coach_fees].all
puts
puts "COACHES"
ap DB[:coaches].all
puts
puts "TIMEZONES"
ap DB[:timezones].all
puts
puts "COHORTS"
ap DB[:cohorts].all
