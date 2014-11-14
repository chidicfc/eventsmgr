require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_new_event"
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
    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,new_event" do |transmitter|
      transmission = Radio::Transmission.new
      transmission.event = event
      t = transmitter.transmit transmission
      p "event created"
      p t
      break
    end

  end

end
