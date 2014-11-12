class LegacyData < Antenna::Band
  def tunnable?
    transimission.tags.include? "legacy_data"
  end
  def tune
    puts "handled by #{self.class} band"
  end
end
