require 'rubygems'
require 'bundler'

Bundler.require

require 'require_all'
require "./web"

require ::File.expand_path('../config/environment',  FILE)
run Sinatra::Application
