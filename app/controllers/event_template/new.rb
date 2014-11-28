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

  def save template
    @template_repo.add template
  end

  def transmit_new_template template
    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,new_event_template,#{settings.environment[0..3]}" do |transmitter|
      transmission = Radio::Transmission.new
      transmission.event_type = OpenStruct.new
      transmission.event_type.title = template.title
      transmission.event_type.description = template.description
      transmission.event_type.id = template.id
      transmission.event_type.duration_hours = template.duration.split(":")[0]
      transmission.event_type.duration_mins = template.duration.split(":")[1]
      transmission.event_type.coaches_fees_attributes = []
      count = 0
      template.coach_fees.each do |coaches_fee|
        transmission.event_type.coaches_fees_attributes << {coaches_fee["currency#{count}".to_sym] => coaches_fee["amount#{count}".to_sym] }
        count += 1
      end
      transmission.event_type.timestamp = Time.now.strftime("%d-%m-%Y %H:%M:%S.%2N")
      t = transmitter.transmit transmission
      p "template created"
      p t
    end
  end
end
