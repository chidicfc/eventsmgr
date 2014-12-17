require "pry"

class CoachUpdate < Antenna::Band
  def tunnable?
    transmission.tags.include? "coach_updated"
  end


  def tune
    begin
      dataset = DB[:coaches]
      if transmission.coach[:delete] == false
        dataset.insert(:id => transmission.coach[:id].to_i, :name => transmission.coach[:name], :email => transmission.coach[:email], :image => transmission.coach[:image], :status => "active") if dataset.where(:id => transmission.coach[:id].to_i).all.empty?
        dataset.where(:id => transmission.coach[:id].to_i).update(:name => transmission.coach[:name], :email => transmission.coach[:email], :image => transmission.coach[:image], :status => "active") unless dataset.where(:id => transmission.coach[:id].to_i).all.empty?

      elsif transmission.coach[:delete] == true
        dataset.where(:id => transmission.coach[:id].to_i).update(:status => "inactive") unless dataset.where(:id => transmission.coach[:id].to_i).all.empty?
      end

    rescue => e
      puts "rescue starting"
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
