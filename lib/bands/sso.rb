require "pry"
require "pry-remote"
require "yeasu/pubnub"

class SSO < Antenna::Band
  def tunnable?
    transmission.tags.include? "sso"
  end
  def tune
    begin
      puts "starting sso transmission"
      m =  Pubnub::Outbound::Message.new
      m.channel = "events-authentication"
      m.body.ok = true
      m.body.sso_token = transmission.sso_token
      m.push

    rescue => e
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
