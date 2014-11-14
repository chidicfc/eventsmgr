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
      transmission.event_type = OpenStruct.new
      transmission.event_type.title = template.title
      transmission.event_type.description = template.description
      transmission.event_type.id = template.id
      transmission.event_type.duration_hours = template.duration.split(":")[0]
      transmission.event_type.duration_mins = template.duration.split(":")[1]
      transmission.event_type.coaches_fees_attributes = []
      template.coach_fees.each do |coaches_fee|
        transmission.event_type.coaches_fees_attributes << {"#{coaches_fee.currency}" => "#{coaches_fee.amount}" }
      end
      t = transmitter.transmit transmission
      p "template created"
      p t
      break
    end
  end
end
