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
    template = @template_repo.get template_id

    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,edit_event_template,deve" do |transmitter|
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
      transmission.event_type.timestamp = Time.now.strftime("%d-%m-%Y %H:%M:%S.%2N")
      t = transmitter.transmit transmission
      p "template updated"
      p t
    end

  end
end
