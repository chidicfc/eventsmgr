require "pry"

class CoachUpdate < Antenna::Band
  def tunnable?
    transmission.tags.include? "coach_updated"
  end
  def tune
    begin
      dataset = DB[:coaches]
      dataset.insert(:id => transmission.id, :name => transmission.name, :email => transmission.email, :image => transmission.image) if dataset.where(:id => transmission.id.to_i).all.empty?
    rescue => e
      puts "rescue starting"
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end