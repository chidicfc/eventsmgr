class CohortRepo

  def initialize
    @store = CoachInABoxOs.new
  end

  def get_cohorts
    @store.get_cohorts
  end

end
