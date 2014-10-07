class CoachFeesRepo

  def initialize
    @datastore = DataBaseDataStore.new
  end

  def default_coach_fees
    @datastore.default_coach_fees
  end

end
