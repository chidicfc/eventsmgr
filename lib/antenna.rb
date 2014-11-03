require 'rubygems'
require 'bundler'


Bundler.require

require 'require_all'
require "./web"


Radio::Tunner.listen_on "in.eventsmanager" do |receiver|

  receiver.receive do |transmission|


    if File.exists?("ciabos.data")
      
      puts "load from file!"
    else
      File.open("ciabos.data", 'w') { |file| file.write(Oj.dump(transmission)) }
      puts "save to file!"
    end


  end


end
