require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_delete_event"
end



class DeleteEventController
  attr_accessor :view

  def initialize(view=nil)
    @event_repo = Event::Repository.new
    @coach_repo = Coach::Repository.new
    @cohort_repo = Cohort::Repository.new
    @view = view
  end

  def get_event template_id, event_id
    @view.event = @event_repo.get_event template_id, event_id
  end

  def get_cohorts
    @view.cohorts = @cohort_repo.get_cohorts
  end

  def get_coaches
    @view.coaches = @coach_repo.get_coaches
  end

  def delete event_id, template_id
    @event_repo.delete_event event_id, template_id
  end

  def transmit_deleted_event event


    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,delete_event,#{settings.environment[0..3]}" do |transmitter|
      transmission = Radio::Transmission.new

      transmission.event = OpenStruct.new
      transmission.event.title = event.title
      transmission.event.date = event.date
      transmission.event.description = event.description
      transmission.event.start_hours = event.start_time.split(":")[0]
      transmission.event.start_mins = event.start_time.split(":")[1]
      transmission.event.duration_hours = event.duration.split(":")[0]
      transmission.event.duration_mins = event.duration.split(":")[1]
      transmission.event.timezone = event.selected_time_zone.split(" ")[1]
      transmission.event.cohort = event.selected_cohort
      transmission.event.coach_fees = event.coach_fees
      transmission.event.income_amount = event.income_amount
      transmission.event.income_currency = event.income_currency
      transmission.event.assigned_coaches = event.assigned_coaches
      transmission.event.event_template_id = event.event_template_id
      transmission.event.id = event.id
      transmission.event.timestamp = Time.now.strftime("%d-%m-%Y %H:%M:%S.%2N")

      t = transmitter.transmit transmission
      p "event deleted"
      p t

    end
  end

end
