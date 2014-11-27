require "pry"
require "yeasu/pubnub"

class SSO < Antenna::Band
  def tunnable?
    transmission.tags.include? "sso"
  end
  def tune
    begin
      binding.pry
      m =  Pubnub::Outbound::Message.new
      m.channel = "events-authentication"
      m.body.ok = true
      m.body.sso_token = "simabaisbad"
      m.push

    rescue => e
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
