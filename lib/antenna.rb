require 'rubygems'
require 'bundler'


Bundler.require

require 'require_all'
require "./web"

Antenna.configure do |config|


  config.bands_folder = "lib/bands"

  config.name = "eventsmanager.ui"
  config.frequency = "in.#{ENV["YEASU_ENV"]}.eventsmanager"

  #used for testing
  # config.replay = true
  # config.record = false

end

Antenna::connect
