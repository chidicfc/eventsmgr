require "pry"

class FieldData < Antenna::Band
  def tunnable?
    transmission.tags.include? "field_data"
  end
  def tune

    binding.pry

    transmission.coaches.each do |coach|
      dataset = DB[:coaches]
      dataset.insert(:name => coach.name, :email => coach.email, :image => coach.image)
    end
    
    puts "handled by #{self.class} band"
  end
end
