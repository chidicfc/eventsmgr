require "active_support/all"

class TimeZone

  attr_accessor :name, :id

  def initialize(name)
    @name = name
  end

  def self.from_hash(row)
    timezone = TimeZone.new(row[:name])
    timezone.id = row[:id]
    timezone
  end

  class Repository

    def initialize
      @datastore = DataBaseDataStore.new
    end

    def get_timezones
      timezones = []
      @datastore.get_timezones do |timezone_row|
        timezone = TimeZone.from_hash(timezone_row)

        time_zone = ActiveSupport::TimeZone.new timezone.name
        timezone.name = "(GMT#{time_zone.formatted_offset}) #{time_zone.name}"
        timezones << timezone
      end
      timezones
    end

  end

end
