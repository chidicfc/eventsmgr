require "pry"

class FieldData < Antenna::Band
  def tunnable?
    transmission.tags.include? "field_data"
  end
  def tune
    begin
      transmission.coaches.each do |coach|
        dataset = DB[:coaches]
        dataset.insert(:id => coach.id, :name => coach.name.capitalize!, :email => coach.email, :image => coach.image, :status => "active") if dataset.where(:id => coach.id.to_i).all == []
      end

      transmission.cohorts.each do |cohort|
        dataset = DB[:cohorts]
        dataset.insert(:id => cohort.id, :name => cohort.name, :status => "active") if dataset.where(:id => cohort.id.to_i).all == []
      end


      timezones = transmission.time_zones.split("|")
      timezones.each do |timezone|
        dataset = DB[:timezones]
        dataset.insert(:name => timezone) if dataset.where(:name => timezone).all == []
      end
    rescue => e
      p e.message
      p e.backtrace
    end

    puts "handled by #{self.class} band"
  end
end
