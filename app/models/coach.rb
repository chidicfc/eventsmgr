class Coach
  attr_accessor :name, :email, :coach_id, :image

  def initialize (coach_id, name, email, image)
    @name = name
    @email = email
    @coach_id = coach_id
    @image = image
  end

  def self.from_hash(row)
    coach = Coach.new(row[:id], row[:name], row[:email], row[:image])
    coach
  end

end
