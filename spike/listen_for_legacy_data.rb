require "yeasu"
require "pry"
require "active_support/all"
require 'yaml'
require 'oj'


include Yeasu
#
# Yeasu::Radio.configuration do |config|
#   config.consumer.name = "eventsmgr"
# end
#
# Radio::Tunner.listen_on "out.ciabos.ui" do |receiver|
#
#   receiver.receive do |transmission|
#     binding.pry
#
#     puts transmission
#
#   end
# end


Radio::Tunner.listen_on "in.#{settings.environment[0..3]}.eventsmanager" do |receiver|

  receiver.receive do |transmission|
    puts transmission.tags

  end


end
