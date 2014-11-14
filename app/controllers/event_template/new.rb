require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_new_event_template"
end

class NewEventTemplateViewController

  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplate::Repository.new
    @coach_fees_repo = CoachesFee::Repository.new
    @view = view
  end

  def get_default_coach_fees
    @view.coach_fees = @coach_fees_repo.default_coach_fees
  end

  def save *args
    @template_repo.add *args
  end

  def transmit_new_template id
    template = @template_repo.get id

    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,new_event_template" do |transmitter|
      transmission = Radio::Transmission.new
      transmission.event_template = template
      t = transmitter.transmit transmission
      p "template created"
      p t
      break
    end
  end
end
