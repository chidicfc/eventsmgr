require 'rubygems'
require 'bundler'

Bundler.require

require 'require_all'
require "./web"


Radio::Tunner.listen_on "out.ciabos.ui" do |receiver|

  receiver.receive do |transmission|
    p transmission
  end

end
