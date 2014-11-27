require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "check_sso_id"
end

class Session
  attr_accessor :sso_id

  def initialize(sso_id)
    @sso_id = sso_id
  end


  def broadcast

    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,stag,sso" do |transmitter|
      transmission = Radio::Transmission.new
      transmission.sso_id = @sso_id

      t = transmitter.transmit transmission
    end

  end

end
