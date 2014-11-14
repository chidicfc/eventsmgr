require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
    config.producer.name = "ui test"
end

class FieldDataResponse < Radio::Transmission
   tags "ciabos,ui,outboud,legacy_data"
end

m =FieldDataResponse.new
m.transmit
