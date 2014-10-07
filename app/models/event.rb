class Event

  attr_accessor :title, :date, :description, :coach_fees, :id
  attr_accessor :start_time, :duration, :event_template_id
  attr_accessor :assigned_coaches, :timezone, :cohort, :coaches
  attr_accessor :income_amount, :income_currency

  def initialize (title, event_template_id)
    @title = title
    @event_template_id = event_template_id
    @assigned_coaches = []
    @coach_fees = []
  end

  def self.from_hash (row)
    event = Event.new row[:title], row[:event_template_id]
    event.id = row[:id]
    event.duration = row[:duration]
    event.description = row[:description]
    event.date = row[:date]
    event.start_time = row[:start_time]
    event.timezone = row[:timezone]
    event.cohort = row[:cohort]
    event.income_amount = row[:income_amount]
    event.income_currency = row[:income_currency]
    event
  end

end
