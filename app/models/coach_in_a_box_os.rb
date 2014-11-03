require_relative "../db"
require "yeasu"
require "pry"
require "active_support/all"

class CoachInABoxOs


  include Yeasu

  Yeasu::Radio.configuration do |config|
    config.producer.name = "eventsmgr"
    config.consumer.name = "eventsmgr"
  end


  def send_request
    Radio::Tunner.broadcast tags: "ciabos,ui,inbound,field_data" do |transmitter|
      transmission = Radio::Transmission.new
      t = transmitter.transmit transmission
    end
  end

  def receive_request
    Radio::Tunner.listen_on "out.ciabos.ui" do |receiver|
      receiver.receive do |transmission|
        puts transmission
      end
    end
  end

  def update_calendar

  end

end
