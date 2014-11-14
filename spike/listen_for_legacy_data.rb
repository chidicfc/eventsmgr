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


Radio::Tunner.listen_on "in.eventsmanager" do |receiver|

  receiver.receive do |transmission|
    puts transmission.tags

    if transmission.tags.include?("legacy_data")

      if File.exists?("legacy_data.yml")
        data = YAML.load(File.open("legacy_data.yml"))


        puts "loaded from legacy_data file!"
      else
        File.open("legacy_data.yml", 'w') { |file| file.write(YAML.dump(transmission)) }
        #File.open("ciabos.data", 'w') { |file| file.write(Oj.dump(transmission)) }
        puts "saved legacy data to file!"
      end
    end


  end


end
