class FieldData < Antenna::Band
  def tunnable?
    transimission.tags.include? "field_data"
  end
  def tune
    puts "handled by #{self.class} band"
  end
end
