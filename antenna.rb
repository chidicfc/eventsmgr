require 'rubygems'
require 'bundler'

Bundler.require

require 'require_all'
require "./web"

include Yeasu

Radio.configuration do |config|
  config.consumer.name = "eventsmgr"
end

Radio::Tunner.listen_on "demo" do |reciever|

  puts "listening!"
  reciever.receive do |transmission|

    if transmission.body == "ok"
      ap transmission
    end

  end
end
