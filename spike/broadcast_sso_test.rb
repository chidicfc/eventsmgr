require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr"
end


Radio::Tunner.broadcast tags: "ciabos,ui,outbound,stag,sso" do |transmitter|

  transmission = Radio::Transmission.new
  transmission.sso_token = "123"
  t = transmitter.transmit transmission



end
