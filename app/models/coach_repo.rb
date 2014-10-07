class CoachRepo

  def initialize
    @store = CoachInABoxOs.new
  end

  def get_coaches
    @store.get_coaches
  end

end
