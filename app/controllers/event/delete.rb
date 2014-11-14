require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_delete_event"
end

class DeleteEventController
  attr_accessor :view

  def initialize(view=nil)
    @event_repo = Event::Repository.new
    @view = view
  end

  def get_event template_id, event_id
    @view.event = @event_repo.get_event template_id, event_id
  end

  def delete event_id, template_id
    @event_repo.delete_event event_id, template_id
  end

  def transmit_deleted_event event


    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,deleted_event" do |transmitter|
      transmission = Radio::Transmission.new
      transmission.event = event
      t = transmitter.transmit transmission
      p "event deleted"
      p t
      break
    end
  end

end
