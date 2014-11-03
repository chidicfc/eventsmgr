require "yeasu"
require "pry"
require "active_support/all"
require 'yaml'


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


Radio::Tunner.listen_on "in.eventsmanager" do |receiver|

  receiver.receive do |transmission|


    if File.exists?("ciabos.yml")
      YAML.load(File.open("ciabos.yml"))

      puts "load from file!"
    else
      File.open("ciabos.yml", 'w') { |file| file.write(transmission.to_yaml) }
      #File.open("ciabos.data", 'w') { |file| file.write(Oj.dump(transmission)) }
      puts "save to file!"
    end


  end


end
