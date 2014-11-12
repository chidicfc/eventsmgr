class LegacyData < Antenna::Band
  def tunnable?
    transmission.tags.include? "legacy_data"
  end
  def tune
    puts "handled by #{self.class} band"
  end
end
