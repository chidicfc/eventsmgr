require "yeasu"
include Yeasu

Yeasu::Radio.configuration do |config|
  config.producer.name = "eventsmgr"
end

Radio::Tunner.broadcast tags: "ciabos,ui,outbound,#{ENV["YEASU_ENV"]},cohort_updated" do |transmitter|

  transmission = Radio::Transmission.new
  transmission.cohort = {:id=>13, :name=>"CiaB Testing Cohort Update Test00"}
  t = transmitter.transmit transmission

end
