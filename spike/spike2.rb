require "./app/db"
require "rubygems"
require "pry"
require "awesome_print"
require "yeasu"

include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_edit_event"
end


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

  def get_utc_time event
    date = event.date.split("/")
    local_time = event.start_time.split(":")
    off_set = event.selected_time_zone.split(" ")[0].split("(GMT")[1].split(")")[0]
    t = Time.new(date[2], date[1], date[0], local_time[0], local_time[1], 0, off_set)
    t.getgm
  end

  def transmit_edited_event event

    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,edit_event,#{ENV["YEASU_ENV"]}" do |transmitter|
      transmission = Radio::Transmission.new

      transmission.event = OpenStruct.new
      transmission.event.assigned_coaches = []
      event.assigned_coaches.each do |assigned_coach|
        transmission.event.assigned_coaches << assigned_coach.coach_id
      end

      transmission.event.title = event.title
      transmission.event.date = event.date
      transmission.event.description = event.description
      transmission.event.start_hours = event.start_time.split(":")[0]
      transmission.event.start_mins = event.start_time.split(":")[1]
      transmission.event.duration_hours = event.duration.split(":")[0]
      transmission.event.duration_mins = event.duration.split(":")[1]
      transmission.event.timezone = event.selected_time_zone.split(" ", 2)[1]
      transmission.event.cohort = event.selected_cohort_id
      transmission.event.coach_fees = event.coach_fees
      transmission.event.income_amount = event.income_amount
      transmission.event.income_currency = event.income_currency

      transmission.event.event_template_id = event.event_template_id
      transmission.event.id = event.id
      transmission.event.timestamp = Time.now.strftime("%d-%m-%Y %H:%M:%S.%2N")
      transmission.event.utc_time = get_utc_time event
      t = transmitter.transmit transmission
      p "event edited"
      p t

    end
  end
end

def getTimeZone
  events = []
  DB[:events].each do |event_row|
    event = Event.from_hash(event_row)
    t = event.selected_time_zone.split(") ")[1]
    timezone = ActiveSupport::TimeZone.new(t)
    zone = timezone.to_s.split(") ")[1]
    off_set = timezone.now.formatted_offset
    event.selected_time_zone = "(GMT#{off_set}) #{zone}"
    events << event
  end
  events
end

def edit_timezone
  events = getTimeZone
  events.each do |event|
    DB[:events].where(:id => event.id).update(:timezone => event.selected_time_zone )
    Event.new(event.title, event.event_template_id).transmit_edited_event event
  end
end

edit_timezone

puts "done"
