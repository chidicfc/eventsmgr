require "yeasu"
require "pry"
require "active_support/all"


include Yeasu

Yeasu::Radio.configuration do |config|
  config.consumer.name = "eventsmgr"
end

Radio::Tunner.listen_on "out.ciabos.ui" do |receiver|

  receiver.receive do |transmission|
    binding.pry

    puts transmission

  end
end
