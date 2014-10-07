require "./lib/events"
require "rubygems"
require "pry"
require "awesome_print"


puts "event templates"
puts DB[:event_templates].all
puts "events"
puts DB[:events].all
puts
puts "assigned_coaches"
puts DB[:assigned_coaches].all
puts
puts "coach_fees"
puts DB[:coach_fees].all


coach_fees = [ {:currency0 => "GBP", :amount0 => "10.00"}, {:currency1 => "USD", :amount1 => "20.00"}, {:currency2 => "EUR", :amount2 => "30.00"}, {:currency3 => "AUD", :amount3 => "40.00"}, { :currency4 => "SGD", :amount4 => "50.00"}]
DB.new
