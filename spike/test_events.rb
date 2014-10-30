require "yeasu"
require "pry"
require "active_support/all"


timezone = ActiveSupport::TimeZone.new 'America/New_York'

value = "(GMT#{timezone.formatted_offset}) #{timezone.name}"

binding.pry
