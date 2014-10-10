require "sequel"

DB = Sequel.sqlite('app/eventsmanager.db')

DB.create_table? :event_templates do
  primary_key :id
  String :title
  String :duration
  String :description
  String :status
end

DB.create_table? :events do
  primary_key :id
  foreign_key :event_template_id
  String :title
  String :duration
  String :description
  String :date
  String :start_time
  String :timezone
  String :cohort
  String :income_amount
  String :income_currency

end

DB.create_table? :coaches do
  primary_key :id
  String :name
  String :email
end

DB.create_table? :assigned_coaches do
  primary_key :id
  foreign_key :event_id
  String :name
end

DB.create_table? :coach_fees do
  primary_key :id
  foreign_key :event_template_id
  foreign_key :event_id
  String :currency
  String :amount
end

DB.create_table? :timezones do
  primary_key :id
  String :name
end

DB.create_table? :cohorts do
  primary_key :id
  String :name
end


class DataBaseDataStore

  def initialize
    @store = CoachInABoxOs.new
  end

  def load_database

    10.times do |index|
      index += 1
      dataset = DB[:event_templates]
      event_template_id = dataset.insert(:title => "Boots Coaching Capability #{index}",:duration => "08:30",:description => "description #{index}", :status => "active")
      load_default_coach_fees event_template_id

      dataset = DB[:events]
      event_id = dataset.insert(:title => "Winchester #{index} - October 11, 2011",:duration => "09:00", :event_template_id => event_template_id, :date => "19/07/2014", :start_time => "09:00", :timezone => "GMT", :cohort => "Apple MAC Division Cohort 1")
      set_default_event_coach_fees event_template_id, event_id

      dataset=DB[:coaches]
      dataset.insert(:name => "Delaney Burke #{index}",:email => "delaney.burke@coachinabox.biz")
      dataset.insert(:name => "Sarah Burke #{index}",:email => "delaney@yahoo.biz")
      dataset.insert(:name => "Michael Jackson #{index}",:email => "m.jackson@coachinabox.biz")
      dataset.insert(:name => "Tom Green #{index}",:email => "tom.green@coachinabox.biz")
      dataset.insert(:name => "Dick Cheney #{index}",:email => "dick.c@coachinabox.biz")
    end
    load_default_coach_fees
    @store.load_coaches
    @store.load_cohorts
    @store.load_timezones
  end

  def load_default_coach_fees template_id=0
    dataset = DB[:coach_fees]
    coach_fee = dataset.insert(:currency => "GBP", :amount => "0.00", :event_template_id => template_id)
    coach_fee = dataset.insert(:currency => "USD", :amount => "0.00", :event_template_id => template_id)
    coach_fee = dataset.insert(:currency => "EUR", :amount => "0.00", :event_template_id => template_id)
    coach_fee = dataset.insert(:currency => "AUD", :amount => "0.00", :event_template_id => template_id)
    coach_fee = dataset.insert(:currency => "SGD", :amount => "0.00", :event_template_id => template_id)
  end

  def set_default_event_coach_fees template_id, event_id
    dataset = DB[:coach_fees]
    coach_fee = dataset.insert(:currency => "GBP", :amount => "0.00", :event_template_id => template_id, :event_id => event_id)
    coach_fee = dataset.insert(:currency => "USD", :amount => "0.00", :event_template_id => template_id, :event_id => event_id)
    coach_fee = dataset.insert(:currency => "EUR", :amount => "0.00", :event_template_id => template_id, :event_id => event_id)
    coach_fee = dataset.insert(:currency => "AUD", :amount => "0.00", :event_template_id => template_id, :event_id => event_id)
    coach_fee = dataset.insert(:currency => "SGD", :amount => "0.00", :event_template_id => template_id, :event_id => event_id)
  end

  def all_templates
    templates = []

    if DB[:event_templates].all == []
      load_database
      all_templates
    else
      DB[:event_templates].where(:status => "active").each do |event_template_row|
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
    end
    templates
  end

  def default_coach_fees
    coach_fees = []
    DB[:coach_fees].where(Sequel.&(:event_template_id => 0, :event_id => nil)).each do |coach_fee_row|
      coach_fee = CoachFee.from_hash(coach_fee_row)
      coach_fees << coach_fee
    end
    coach_fees
  end

  def add *args
    values = [*args]
    DB.transaction do
      template_id = DB[:event_templates].insert(:title => values[0], :duration => values[1], :description => values[3], :status => "active")
      count = 0
      values[2].each do |value|
        DB[:coach_fees].insert(:currency => value["currency#{count}".to_sym], :amount => value["amount#{count}".to_sym], :event_template_id => template_id)
        count += 1
      end
    end
  end

  def get template_id
    DB[:event_templates].where(:id => template_id).each do |event_template_row|
      @event_template = EventTemplate.from_hash(event_template_row)
      DB[:events].where(:event_template_id => event_template_row[:id]).each do |event_row|
        event = Event.from_hash(event_row)
        if DB[:assigned_coaches].where(:event_id=> event_row[:id]) != []
          DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
            assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
            event.assigned_coaches << assigned_coach
          end
        end
        @event_template.events << event
      end

      DB[:coach_fees].where(:event_template_id => template_id, :event_id => nil).each do |coach_fee_row|
        coach_fee = CoachFee.from_hash(coach_fee_row)
        @event_template.coach_fees << coach_fee
      end
    end
    @event_template
  end

  def update_template *args
    values = [*args]

    DB.transaction do
      DB[:event_templates].where(:id => values[0]).update(:title => values[1], :duration => values[2], :description => values[4])
      count = 0
      values[3].each do |value|
        @currency = value["currency#{count}".to_sym]
        @amount = value["amount#{count}".to_sym]
        DB[:coach_fees].where(:event_template_id => values[0], :event_id => nil, :currency => @currency).update(:amount => @amount)
        count += 1
      end
    end
  end

  def delete_template id
    if (get id).events.count == 0
      DB.transaction do
        DB[:event_templates].where(:id => id).delete
        DB[:coach_fees].where(:event_template_id => id, :event_id => nil).delete
      end
    end
  end

  def archive_template id
    event_template = get id
    if isArchive? event_template.events
      DB[:event_templates].where(:id => id).update(:status => "archive")
    end
  end

  def show_archive
    archive_templates = []
    DB[:event_templates].where(:status => "archive").each do |event_template_row|
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

      archive_templates << event_template
    end
    archive_templates
  end

  def unarchive_template id
    DB[:event_templates].where(:id => id).update(:status => "active")
  end

  def isArchive? events
    value = true
    events.each do |event|
      value = false if Date.today <= (Date.parse(event.date) + 2)
    end
    value
  end

  def add_event template_id, title, duration, description, start_date, start_time, timezone, cohort, coaches_fee, assigned_coaches, income_amount, income_currency
    DB.transaction do
      event_id = DB[:events].insert(:event_template_id => template_id, :title => title, :duration => duration, :description => description, :date => start_date, :start_time => start_time, :timezone => timezone, :cohort => cohort, :income_amount => income_amount, :income_currency => income_currency)

      coaches_fee.each do |currency, amount|
        DB[:coach_fees].insert(:event_template_id => template_id, :event_id => event_id, :currency => currency, :amount => amount)
      end
      if assigned_coaches != []
        assigned_coaches.each do |assigned_coach|
          DB[:assigned_coaches].insert(:event_id => event_id, :name => assigned_coach)
        end
      end
    end
  end

  def update_event template_id, event_id, sub_title, duration, description, date, start_time, timezone, cohort, coach_fees, assigned_coaches, income_amount, income_currency
    DB.transaction do
      DB[:events].where(:event_template_id => template_id, :id => event_id).update(:title => sub_title, :duration => duration, :description => description, :date => date, :start_time => start_time, :timezone => timezone, :cohort => cohort, :income_amount => income_amount, :income_currency => income_currency)

      coach_fees.each do |coach_fee|
        coach_fee.each do |currency, amount|
          DB[:coach_fees].where(:event_template_id => template_id, :event_id => event_id, :currency => currency).update(:amount => amount)
        end
      end

      DB[:assigned_coaches].where(:event_id => event_id).delete
      assigned_coaches.each do |assigned_coach|
        DB[:assigned_coaches].insert(:event_id => event_id, :name => assigned_coach)
      end

    end
  end

  def reset_db
    DB.transaction do
      DB.run("DROP TABLE event_templates")
      DB.run("DROP TABLE events")
      DB.run("DROP TABLE coaches")
      DB.run("DROP TABLE assigned_coaches")
      DB.run("DROP TABLE coach_fees")
      DB.run("DROP TABLE timezones")
      DB.run("DROP TABLE cohorts")
    end
  end


  def get_event template_id, event_id
    DB[:events].where(:id => event_id).each do |event_row|
      @event = Event.from_hash(event_row)

      DB[:coach_fees].where(Sequel.&(:event_id => event_id, :event_template_id => template_id)).each do |coach_fee_row|
        coach_fee = CoachFee.from_hash(coach_fee_row)
        @event.coach_fees << {"#{coach_fee.currency}" => "#{coach_fee.amount}"}
      end

      DB[:assigned_coaches].where(:event_id => event_id).each do |assigned_coach_row|
        assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
        @event.assigned_coaches << assigned_coach.name
      end
    end
    @event
  end

  def delete_event event_id, template_id
    DB.transaction do
      DB[:events].where(:id => event_id).delete
      DB[:assigned_coaches].where(:event_id => event_id).delete
      DB[:coach_fees].where(:event_template_id => template_id, :event_id => event_id).delete
    end
  end

  def search_templates_by_letter letter, status
    templates = []
    DB[:event_templates].where(Sequel.like(:title, "#{letter}%")).where(:status => status).each do |event_template_row|
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



  def search_templates_by_name name, status
    templates = []
    capitalize_name = name.capitalize
    lowercase_name = name.downcase

    DB[:event_templates].where(Sequel.|(Sequel.like(:title, "%#{capitalize_name}%"), Sequel.like(:title, "%#{lowercase_name}%") ) ).where(:status => status).each do |event_template_row|
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

end
