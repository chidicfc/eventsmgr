require "yeasu"
require "pry"
require "active_support/all"
require 'yaml'
require 'oj'


if File.exists?("legacy_data.yml")
  data = YAML.load(File.open("ciabos.yml"))
  binding.pry

  puts "loaded from ciabos file!"
end
