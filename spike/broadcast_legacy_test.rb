require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr"
end


Radio::Tunner.broadcast tags: "ciabos,ui,outbound,#{settings.environment[0..3]},legacy" do |transmitter|

  transmission = Radio::Transmission.new
  transmission.event_types = OpenStruct.new
  transmission.event_types = []
  event_type = OpenStruct.new
  event_type.title = "test broadcast"
  event_type.description = "template"
  event_type.id = "ff08f280-54d8-0132-115d-6476baaeb9c4"
  event_type.duration = "30 minutes"
  event_type.coaches_fees = []
  event_type.events = []
  event_type.timestamp = Time.now.strftime("%d-%m-%Y %H:%M:%S.%2N")
  transmission.event_types << event_type
  t = transmitter.transmit transmission
  puts "Request sent for test data in transmission of id: #{t.id}"
  puts transmission


end
