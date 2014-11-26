require "pry"
require "yeasu/pubnub"

class SSO < Antenna::Band
  def tunnable?
    transmission.tags.include? "sso"
  end
  def tune
    begin

      m =  Pubnub::Outbound::Message.new
      m.channel = "events-authentication"
      m.body.sso_token = transmission.sso_id
      m.body.ok = true
      m.transmit_on_outbound

    rescue => e
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
