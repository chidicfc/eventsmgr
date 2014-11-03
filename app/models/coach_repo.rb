class CoachRepo

  def initialize
    @datastore = DataBaseDataStore.new
  end

  def get_coaches
    @datastore.get_coaches
  end

  def search_coaches_by_letter letter
    @datastore.search_coaches_by_letter letter
  end

end
