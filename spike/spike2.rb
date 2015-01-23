require "./app/db"
require "rubygems"
require "pry"
require "awesome_print"


class Event

  attr_accessor :title, :date, :description, :coach_fees, :id, :utc_time
  attr_accessor :start_time, :duration, :event_template_id
  attr_accessor :assigned_coaches, :selected_time_zone, :selected_cohort_id, :coaches
  attr_accessor :income_amount, :income_currency, :coaches_emails, :selected_cohort

  def initialize (title, event_template_id)
    @title = title
    @event_template_id = event_template_id
    @assigned_coaches = []
    @coach_fees = []
    @coaches_emails = []
    @id = SecureRandom.uuid
  end

  def self.from_hash (row)
    event = Event.new row[:title], row[:event_template_id]
    event.id = row[:id]
    event.duration = row[:duration]
    event.description = row[:description]
    event.date = row[:date]
    event.start_time = row[:start_time]
    event.selected_time_zone = row[:timezone]
    event.selected_cohort_id = row[:cohort_id]
    event.income_amount = row[:income_amount]
    event.income_currency = row[:income_currency]
    event.utc_time = row[:utc_time]
    event
  end
end

def getTimeZone
  events = []
  DB[:events].each do |event_row|
    begin
      event = Event.from_hash(event_row)
      t = event.selected_time_zone.split(") ")[1]
      timezone = ActiveSupport::TimeZone.new(t)
      zone = timezone.to_s.split(") ")[1]
      off_set = timezone.now.formatted_offset
      event.selected_time_zone = "(GMT#{off_set}) #{zone}"
    rescue Exception => e
      binding.remote_pry
    end
    events << event
  end
  events
end

def edit_timezone
  events = getTimeZone
  events.each do |event|
    DB[:events].where(:id => event.id).update(:timezone => event.selected_time_zone )
  end
end

edit_timezone

puts "done"
