require "pry"

class CoachUpdate < Antenna::Band
  def tunnable?
    transmission.tags.include? "coach_updated"
  end
  def tune
    begin
      DB[:coaches].insert(:id => coach.id, :name => coach.name, :email => coach.email, :image => coach.image) if dataset.where(:id => coach.id.to_i).all.empty?
    rescue => e
      puts "rescue starting"
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
