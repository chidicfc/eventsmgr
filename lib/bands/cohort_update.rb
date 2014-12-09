require "pry"

class CohortUpdate < Antenna::Band
  def tunnable?
    transmission.tags.include? "cohort_updated"
  end
  def tune
    begin
      DB[:cohorts].insert(:id => transmission.cohort.id, :name => transmission.cohort.name) if dataset.where(:id => transmission.cohort.id.to_i).all.empty?
    rescue => e
      puts "rescue starting"
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
