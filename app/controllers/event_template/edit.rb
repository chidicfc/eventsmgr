require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_updated_event_template"
end


class EditEventTemplateViewController
  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplate::Repository.new
    @view = view
  end

  def split_time time
    time.split(":")
  end

  def get template_id
    @view.template = @template_repo.get template_id
    @view.template.duration = split_time @view.template.duration
  end

  def update *args
    @template_repo.update_template *args
  end

  def transmit_updated_template template_id
    template = get template_id

    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,updated_event_template" do |transmitter|
      transmission = Radio::Transmission.new
      transmission.event_template = template
      t = transmitter.transmit transmission
      p "template created"
      p t
      break
    end

  end
end
