require "./app/db"
require "rubygems"
require "pry"
require "awesome_print"
require "yeasu"
require "active_support/all"

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

class CoachesFee
  attr_accessor :currency, :amount, :template_id, :event_id, :id

  def initialize(currency, amount, template_id)
    @currency = currency
    @amount = amount
    @template_id = template_id
  end

  def self.from_hash(row)
    coach_fee = CoachesFee.new row[:currency],row[:amount],row[:event_template_id]
    coach_fee.event_id = row[:event_id]
    coach_fee.id = row[:id]
    coach_fee
  end
end

class AssignedCoach
  attr_accessor :id, :event_id, :coach_id

  def initialize (id, event_id, coach_id)
    @id = id
    @event_id = event_id
    @coach_id = coach_id
  end

  def self.from_hash(row)
    assigned_coach = AssignedCoach.new row[:id], row[:event_id], row[:coach_id]
    assigned_coach
  end
end

class Coach
  attr_accessor :name, :email, :coach_id, :image

  def initialize (coach_id, name, email, image)
    @name = name
    @email = email
    @coach_id = coach_id
    @image = image
  end

  def self.from_hash(row)
    coach = Coach.new(row[:id], row[:name], row[:email], row[:image])
    coach
  end
end

class Cohort

  attr_accessor :name, :id

  def initialize(name)
    @name = name
  end

  def self.from_hash(row)
    cohort = Cohort.new(row[:name])
    cohort.id = row[:id]
    cohort
  end
end

def get_cohort id
  cohort_name = nil
  DB[:cohorts].where(:id => id, :status => "active").each do |cohort_row|
    cohort = Cohort.from_hash(cohort_row)
    cohort_name = cohort.name
  end
  cohort_name
end

def get_event template_id, event_id
  DB[:events].where(:id => event_id).each do |event_row|
    @event = Event.from_hash(event_row)
    @event.selected_cohort = get_cohort @event.selected_cohort_id

    DB[:coach_fees].where(Sequel.&(:event_id => event_id, :event_template_id => template_id)).each do |coach_fee_row|
      coach_fee = CoachesFee.from_hash(coach_fee_row)
      @event.coach_fees << {"#{coach_fee.currency}" => "#{coach_fee.amount}"}
    end


    DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
      assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
      DB[:coaches].order(:name).where(:id => assigned_coach.coach_id, :status => "active").each do |coach_row|
        coach = Coach.from_hash(coach_row)
        @event.coaches_emails << coach.email
        @event.assigned_coaches << coach
      end
    end

  end
  @event
end

def getTimeZone
  events = []
  DB[:events].each do |event_row|
    event = Event.from_hash(event_row)
    t = event.selected_time_zone
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
  end

  events.each do |event|
    @event = get_event event.event_template_id, event.id
    Event.new(@event.title, @event.event_template_id).transmit_edited_event @event
  end
end

edit_timezone

puts "done"
