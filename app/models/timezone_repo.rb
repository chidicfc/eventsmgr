class TimezoneRepo

  def initialize
    @datastore = DataBaseDataStore.new
  end

  def get_timezones
    @datastore.get_timezones
  end

end
