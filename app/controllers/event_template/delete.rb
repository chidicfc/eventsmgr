require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr_deleted_event_template"
end

class DeleteEventTemplateController

  def initialize
    @template_repo = EventTemplate::Repository.new
  end

  def delete id
    @template_repo.delete_template id
  end

  def get template_id
    @template_repo.get template_id
  end

  def transmit_deleted_template template
    #template = @template_repo.get id
    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,delete_event_template" do |transmitter|
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
      p "template deleted"
      p t
    end

  end

end
