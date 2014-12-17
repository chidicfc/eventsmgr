require "pry"

class CohortUpdate < Antenna::Band
  def tunnable?
    transmission.tags.include? "cohort_updated"
  end

  def tune
    begin
      dataset = DB[:cohorts]
      if transmission.cohort[:delete] == true
        dataset.where(:id => transmission.cohort[:id].to_i).update(:status => "inactive") unless dataset.where(:id => transmission.cohort[:id].to_i).all.empty?
      else
        dataset.insert(:id => transmission.cohort[:id].to_i, :name => transmission.cohort[:name], :status => "active") if dataset.where(:id => transmission.cohort[:id].to_i).all.empty?
        dataset.where(:id => transmission.cohort[:id].to_i).update(:id => transmission.cohort[:id].to_i, :name => transmission.cohort[:name], :status => "active") unless dataset.where(:id => transmission.cohort[:id].to_i).all.empty?
      end

    rescue => e
      puts "rescue starting"
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
