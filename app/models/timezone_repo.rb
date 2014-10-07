class TimezoneRepo

  def initialize
    @store = CoachInABoxOs.new
  end

  def get_timezones
    @store.get_timezones
  end

end
