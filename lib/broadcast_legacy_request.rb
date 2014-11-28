require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr"
end


Radio::Tunner.broadcast tags: "ciabos,ui,inbound,legacy_data,#{settings.environment[0..3]}" do |transmitter|
  transmission = Radio::Transmission.new

  t = transmitter.transmit transmission
  puts "Request sent for legacy data in transmission of id: #{t.id}"
  break
end
