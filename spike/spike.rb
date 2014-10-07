require "rubygems"
require "pry"
require "awesome_print"
require "require_all"



require_all "app"


def search_templates_by_name name, status
  templates = []
  cap_name = name.capitalize
  low_name = name.downcase

  DB[:event_templates].where(Sequel.|(Sequel.like(:title, "%#{cap_name}%"), Sequel.like(:title, "%#{low_name}%") ) ).where(:status => status).each do |event_template_row|
    event_template = EventTemplate.from_hash(event_template_row)
    DB[:events].where(:event_template_id => event_template_row[:id]).each do |event_row|
      event = Event.from_hash(event_row)
      if DB[:assigned_coaches].where(:event_id=> event_row[:id]) != []
        DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
          assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
          event.assigned_coaches << assigned_coach
        end
      end
      event_template.events << event
    end

    DB[:coach_fees].where(Sequel.&(:event_template_id => event_template_row[:id], :event_id => nil)).each do |coach_fee_row|
      coach_fee = CoachFee.from_hash(coach_fee_row)
      event_template.coach_fees << coach_fee
    end

    templates << event_template
  end
  templates
end

# DB[:event_templates].where(Sequel.|(Sequel.like(:title, "%#{cap_name}%"), Sequel.like(:title, "%#{low_name}%") ) )
# items.where{Sequel.|({:category => ['ruby', 'other']}, (:price - 100 > 200))}.sql
#
#  {Sequel.|({:category => ['ruby', 'other']}, (:price - 100 > 200))}
#
#  ({:category => ['ruby', 'other']}, (:price - 100 > 200))
#
a = search_templates_by_name "boots", "active"

puts a.inspect

# ae = DB[:event_templates].where(Sequel.like(:title, "B%"))
# puts ae.all
