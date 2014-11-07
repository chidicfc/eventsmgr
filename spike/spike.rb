require "yeasu"
require "pry"
require "active_support/all"
require 'yaml'
require 'oj'


if File.exists?("legacy_data.yml")
  data = YAML.load(File.open("legacy_data.yml"))
  binding.pry

  puts "loaded from legacy_data file!"
end
