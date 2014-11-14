class All < Antenna::Band
  def tunnable?
    true
  end
  def tune
    puts "handled by #{self.class} band"
  end
end
