require "yeasu"
require "pry-remote"
# require "resolv-replace.rb"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_new_event"
end


class EventTransmission < Radio::Transmission
  tags "ciabos,ui,inbound,new_event,#{ENV["YEASU_ENV"]}"
end

class NewEventViewController
  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplate::Repository.new
    @event_repo = Event::Repository.new
    @coach_repo = Coach::Repository.new
    @timezone_repo = TimeZone::Repository.new
    @cohort_repo = Cohort::Repository.new
    @view = view
  end

  def get template_id
    @view.template = @template_repo.get template_id
  end

  def get_coaches
    @view.coaches = @coach_repo.get_coaches
  end

  def get_timezones
    @view.timezones = @timezone_repo.get_timezones
  end

  def get_cohorts
    @view.cohorts = @cohort_repo.get_cohorts
  end

  def display_coaches_by_letter letter
    @view.event.searched_coaches = @coach_repo.search_coaches_by_letter letter
  end

  def add_event event
    @event_repo.add_event event
  end

  def transmit_new_event event


    transmission = EventTransmission.new

    transmission.event = OpenStruct.new
    transmission.event.title = event.title
    transmission.event.date = event.date
    transmission.event.description = event.description
    transmission.event.start_hours = event.start_hours
    transmission.event.start_mins = event.start_mins
    transmission.event.duration_hours = event.duration_hours
    transmission.event.duration_mins = event.duration_mins
    transmission.event.timezone = event.selected_time_zone.split(" ", 2)[1]
    transmission.event.cohort = event.selected_cohort_id
    transmission.event.coach_fees = event.coach_fees
    transmission.event.income_amount = event.income_amount
    transmission.event.income_currency = event.selected_income_currency
    transmission.event.assigned_coaches = event.assigned_coaches
    transmission.event.event_template_id = event.event_template_id
    transmission.event.id = event.id

    transmission.transmit

  end

end
