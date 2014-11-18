web: bundle exec rackup config.ru -p $PORT
radio: ruby lib/antenna.rb

worker: ruby lib/broadcast_legacy_request.rb
worker: ruby lib/broadcast_field_data.rb
