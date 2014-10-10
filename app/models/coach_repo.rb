class CoachRepo

  def initialize
    @store = CoachInABoxOs.new
  end

  def get_coaches
    @store.get_coaches
  end

  def search_coaches_by_letter letter
    @store.search_coaches_by_letter letter
  end

end
