class Coach
  attr_accessor :name, :email, :coach_id

  def initialize (coach_id, name, email)
    @name = name
    @email = email
    @coach_id = coach_id
  end

  def self.from_hash(row)
    coach = Coach.new(row[:id], row[:name], row[:email])
    coach
  end

end
