class TimeZone

  attr_accessor :name, :id

  def initialize(name)
    @name = name
  end

  def self.from_hash(row)
    timezone = TimeZone.new(row[:name])
    timezone.id = row[:id]
    timezone
  end

end
