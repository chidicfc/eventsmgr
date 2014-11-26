require "pry"

class SSO < Antenna::Band
  def tunnable?
    transmission.tags.include? "sso"
  end
  def tune
    begin
      puts transmission
    rescue => e
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
