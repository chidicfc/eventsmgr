require 'rubygems'
require 'bundler'

Bundler.require

require 'require_all'
require "./web"

run Sinatra::Application
