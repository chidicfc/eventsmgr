require "pry"

class TestData < Antenna::Band

  def tunnable?
    puts "test"
    puts transmission.tags
    transmission.tags.include? "test"
  end

  def tune
    puts "test"
  end
end
