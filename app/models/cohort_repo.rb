class CohortRepo

  def initialize
    @datastore = DataBaseDataStore.new
  end

  def get_cohorts
    @datastore.get_cohorts
  end

end
