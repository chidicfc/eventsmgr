require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr"
end


Radio::Tunner.broadcast tags: "ciabos,ui,inbound,field_data,stag" do |transmitter|
  transmission = Radio::Transmission.new

  t = transmitter.transmit transmission
  puts "Request sent for field data in transmission of id: #{t.id}"
  break
end
