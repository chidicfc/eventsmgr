class Event

  attr_accessor :title, :date, :description, :coach_fees, :id
  attr_accessor :start_time, :duration, :event_template_id
  attr_accessor :assigned_coaches, :selected_time_zone, :selected_cohort, :coaches
  attr_accessor :income_amount, :income_currency, :coaches_emails

  def initialize (title, event_template_id)
    @title = title
    @event_template_id = event_template_id
    @assigned_coaches = []
    @coach_fees = []
    @coaches_emails = []
    @id = UUID.new.generate
  end

  def self.from_hash (row)
    event = Event.new row[:title], row[:event_template_id]
    event.id = row[:id]
    event.duration = row[:duration]
    event.description = row[:description]
    event.date = row[:date]
    event.start_time = row[:start_time]
    event.selected_time_zone = row[:timezone]
    event.selected_cohort = row[:cohort]
    event.income_amount = row[:income_amount]
    event.income_currency = row[:income_currency]
    event
  end

  class Repository

    def initialize
      @datastore = DataBaseDataStore.new
    end

    def add_event event
      @datastore.add_event event
    end

    def get_event template_id, event_id
      @datastore.get_event template_id, event_id
    end

    def edit_event event
      @datastore.update_event event
    end

    def delete_event event_id, template_id
      @datastore.delete_event event_id, template_id
    end

  end

end
