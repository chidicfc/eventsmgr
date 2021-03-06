require "sequel"
require 'pry-remote'
require 'yaml'
require 'chronic_duration'
require 'date'
require 'sinatra'
require "active_support/all"


# DB = Sequel.sqlite('app/eventsmanager.db')
# DB = Sequel.connect('postgres://localhost:5432/eventsmgr')

configure :production do
  DB = Sequel.connect ENV['DATABASE_URL']
  set :environment, :production
end

configure :staging do
  DB = Sequel.connect ENV['DATABASE_URL']
  set :environment, :staging
end

configure :development do
  DB = Sequel.connect('postgres://localhost:5432/eventsmgr')
  set :environment, :development
end

# configure :test do
#   DB = Sequel.connect ENV['DATABASE_URL']
#   set :environment, :test
# end

def create_tables
  DB.create_table? :event_templates do
    primary_key :id, :type => :uuid
    String :title, :unique=>true
    String :duration
    String :description
    String :status
  end

  DB.create_table? :events do
    primary_key :id, :type => :uuid
    foreign_key :event_template_id, :type => :uuid
    String :title
    String :duration
    String :description
    String :date
    String :start_time
    String :timezone
    String :cohort
    Integer :cohort_id
    String :income_amount
    String :income_currency
    String :utc_time

  end

  DB.create_table? :coaches do
    primary_key :id
    String :name
    String :email
    String :image
    String :status
  end

  DB.create_table? :assigned_coaches do
    primary_key :id
    foreign_key :event_id, :type => :uuid
    foreign_key :coach_id
  end

  DB.create_table? :coach_fees do
    primary_key :id
    foreign_key :event_template_id, :type => :uuid
    foreign_key :event_id, :type => :uuid
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
    String :status
  end

end

create_tables


class DataBaseDataStore

  def get_coaches
    coaches = []
    DB[:coaches].order(:name).where(:status => "active").each do |coach_row|
      coach = Coach.from_hash(coach_row)
      coaches << coach
    end
    coaches
  end

  def get_coach id
    coach = nil
    DB[:coaches].where(:id => id, :status => "active").each do |coach_row|
      coach = Coach.from_hash(coach_row)
    end
    coach
  end


  def search_coaches_by_letter letter
    coaches = []
    DB[:coaches].order(:name).where(:status => "active").where(Sequel.like(:name, "#{letter}%")).each do |coach_row|
      coach = Coach.from_hash(coach_row)
      coaches << coach
    end
    coaches
  end

  def get_timezones
    DB[:timezones].each do |timezone_row|
      yield timezone_row
    end
  end

  def get_cohorts
    cohorts = []
    DB[:cohorts].order(:name).where(:status => "active").each do |cohort_row|
      cohort = Cohort.from_hash(cohort_row)
      cohorts << cohort
    end
    cohorts
  end

  #template_id_default = UUID.new.generate;

  def load_default_coach_fees template_id="123e4567-e89b-12d3-a456-426655440000"
    dataset = DB[:coach_fees]
    coach_fee = dataset.insert(:currency => "GBP", :amount => "0.00", :event_template_id => template_id) if dataset.where(:currency => "GBP", :amount => "0.00", :event_template_id => template_id, :event_id => nil).all == []
    coach_fee = dataset.insert(:currency => "USD", :amount => "0.00", :event_template_id => template_id) if dataset.where(:currency => "USD", :amount => "0.00", :event_template_id => template_id, :event_id => nil).all == []
    coach_fee = dataset.insert(:currency => "EUR", :amount => "0.00", :event_template_id => template_id) if dataset.where(:currency => "EUR", :amount => "0.00", :event_template_id => template_id, :event_id => nil).all == []
    coach_fee = dataset.insert(:currency => "AUD", :amount => "0.00", :event_template_id => template_id) if dataset.where(:currency => "AUD", :amount => "0.00", :event_template_id => template_id, :event_id => nil).all == []
    coach_fee = dataset.insert(:currency => "SGD", :amount => "0.00", :event_template_id => template_id) if dataset.where(:currency => "SGD", :amount => "0.00", :event_template_id => template_id, :event_id => nil).all == []
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

    unless DB[:event_templates].all == []

      DB[:event_templates].order(:title).where(:status => "active").each do |event_template_row|
        event_template = EventTemplate.from_hash(event_template_row)
        DB[:events].order(:title).where(:event_template_id => event_template_row[:id]).each do |event_row|
          event = Event.from_hash(event_row)
          if DB[:assigned_coaches].where(:event_id=> event_row[:id]) != []
            DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
              assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
              DB[:coaches].order(:name).where(:id => assigned_coach.coach_id, :status => "active").each do |coach_row|
                coach = Coach.from_hash(coach_row)
                event.coaches_emails << coach.email
                event.assigned_coaches << coach
              end
            end
          end
          event_template.events << event
        end

        DB[:coach_fees].where(Sequel.&(:event_template_id => event_template_row[:id], :event_id => nil)).each do |coach_fee_row|
          coach_fee = CoachesFee.from_hash(coach_fee_row)
          event_template.coach_fees << coach_fee
        end

        event_template.isArchive = isArchive? event_template.events

        templates << event_template
      end
    end
    templates
  end

  def default_coach_fees
    coach_fees = []
    DB[:coach_fees].where(Sequel.&(:event_template_id => "123e4567-e89b-12d3-a456-426655440000", :event_id => nil)).each do |coach_fee_row|
      coach_fee = CoachesFee.from_hash(coach_fee_row)
      coach_fees << coach_fee
    end
    coach_fees
  end

  def get_cohort_id name
    cohort_id = nil
    DB[:cohorts].where(:name => name, :status => "active").each do |cohort_row|
      cohort = Cohort.from_hash(cohort_row)
      cohort_id = cohort.id
    end
    cohort_id
  end

  def add template
    template.id = UUID.new.generate
    DB.transaction do
      DB[:event_templates].insert(:id => template.id, :title => template.title, :duration => template.duration, :description => template.description, :status => "active")

      count = 0
      template.coach_fees.each do |coach_fee|
        DB[:coach_fees].insert(:currency => coach_fee["currency#{count}".to_sym], :amount => coach_fee["amount#{count}".to_sym], :event_template_id => template.id)
        count += 1
      end
    end
  end

  def get template_id
    DB[:event_templates].where(:id => template_id).each do |event_template_row|
      @event_template = EventTemplate.from_hash(event_template_row)
      DB[:events].order(:title).where(:event_template_id => event_template_row[:id]).each do |event_row|
        event = Event.from_hash(event_row)
        if DB[:assigned_coaches].where(:event_id=> event_row[:id]) != []
          DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
            assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
            DB[:coaches].order(:name).where(:id => assigned_coach.coach_id, :status => "active").each do |coach_row|
              coach = Coach.from_hash(coach_row)
              event.assigned_coaches << coach
            end
          end
        end
        @event_template.events << event
      end

      DB[:coach_fees].where(:event_template_id => template_id, :event_id => nil).each do |coach_fee_row|
        coach_fee = CoachesFee.from_hash(coach_fee_row)
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
            DB[:coaches].order(:name).where(:id => assigned_coach.coach_id, :status => "active").each do |coach_row|
              coach = Coach.from_hash(coach_row)
              event.coaches_emails << coach.email
              event.assigned_coaches << coach
            end
          end
        end
        event_template.events << event
      end

      DB[:coach_fees].where(Sequel.&(:event_template_id => event_template_row[:id], :event_id => nil)).each do |coach_fee_row|
        coach_fee = CoachesFee.from_hash(coach_fee_row)
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
      value = false if Date.today <= Date.parse(event.date)
    end
    value
  end

  def add_event event
    event.id = UUID.new.generate
    DB.transaction do
      DB[:events].insert(:id => event.id, :event_template_id => event.event_template_id, :title => event.title, :duration => event.duration, :description => event.description, :date => event.date, :start_time => event.start_time, :timezone => event.selected_time_zone, :cohort_id => event.selected_cohort_id, :income_amount => event.income_amount, :income_currency => event.income_currency, :utc_time => event.utc_time)


      event.coach_fees.each do |coaches_fee|
        coaches_fee.each do |currency, amount|
          DB[:coach_fees].insert(:event_template_id => event.event_template_id, :event_id => event.id, :currency => currency, :amount => amount)
        end
      end

      if event.assigned_coaches != []
        event.assigned_coaches.each do |assigned_coach|
          #find coach by name
          DB[:coaches].where(:id => assigned_coach.coach_id, :status => "active").each do |assigned_coach_row|
            assigned_coach = Coach.from_hash(assigned_coach_row)
            DB[:assigned_coaches].insert(:event_id => event.id, :coach_id => assigned_coach.coach_id)
          end
        end
      end
    end
  end

  def update_event event
    #template_id, event_id, sub_title, duration, description, date, start_time, timezone, cohort, coach_fees, assigned_coaches, income_amount, income_currency
    DB.transaction do

      DB[:events].where(:event_template_id => event.event_template_id, :id => event.id).update(:cohort_id => event.selected_cohort_id,:title => event.title, :duration => event.duration, :description => event.description, :date => event.date, :start_time => event.start_time, :timezone => event.selected_time_zone, :cohort => event.selected_cohort, :income_amount => event.income_amount, :income_currency => event.income_currency, :utc_time => event.utc_time)

      event.coach_fees.each do |coach_fee|
        coach_fee.each do |currency, amount|
          DB[:coach_fees].where(:event_template_id => event.event_template_id, :event_id => event.id, :currency => currency).update(:amount => amount)
        end
      end

      DB[:assigned_coaches].where(:event_id => event.id).delete

      event.assigned_coaches.each do |assigned_coach|
        DB[:assigned_coaches].insert(:event_id => event.id, :coach_id => assigned_coach.coach_id)
      end

    end
  end

  def reset_db
    binding.remote_pry
    DB.transaction do
      DB.run("DROP TABLE event_templates")
      DB.run("DROP TABLE events")
      DB.run("DROP TABLE assigned_coaches")
      DB.run("DROP TABLE coaches")
      DB.run("DROP TABLE coach_fees")
      DB.run("DROP TABLE timezones")
      DB.run("DROP TABLE cohorts")



      create_tables
    end
  end

  def get_cohort id
    cohort_name = nil
    DB[:cohorts].where(:id => id, :status => "active").each do |cohort_row|
      cohort = Cohort.from_hash(cohort_row)
      cohort_name = cohort.name
    end
    cohort_name
  end

  #check this
  def get_event template_id, event_id
    DB[:events].where(:id => event_id).each do |event_row|
      @event = Event.from_hash(event_row)
      @event.selected_cohort = get_cohort @event.selected_cohort_id

      DB[:coach_fees].where(Sequel.&(:event_id => event_id, :event_template_id => template_id)).each do |coach_fee_row|
        coach_fee = CoachesFee.from_hash(coach_fee_row)
        @event.coach_fees << {"#{coach_fee.currency}" => "#{coach_fee.amount}"}
      end


      DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
        assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
        DB[:coaches].order(:name).where(:id => assigned_coach.coach_id, :status => "active").each do |coach_row|
          coach = Coach.from_hash(coach_row)
          @event.coaches_emails << coach.email
          @event.assigned_coaches << coach
        end
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
    DB[:event_templates].order(:title).where(Sequel.like(:title, "#{letter}%")).where(:status => status).each do |event_template_row|
      event_template = EventTemplate.from_hash(event_template_row)
      DB[:events].order(:title).where(:event_template_id => event_template_row[:id]).each do |event_row|
        event = Event.from_hash(event_row)
        if DB[:assigned_coaches].where(:event_id=> event_row[:id]) != []
          DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
            assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
            DB[:coaches].order(:name).where(:id => assigned_coach.coach_id).each do |coach_row|
              coach = Coach.from_hash(coach_row)
              event.coaches_emails << coach.email
              event.assigned_coaches << coach
            end
          end
        end
        event_template.events << event
      end

      DB[:coach_fees].where(Sequel.&(:event_template_id => event_template_row[:id], :event_id => nil)).each do |coach_fee_row|
        coach_fee = CoachesFee.from_hash(coach_fee_row)
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

    DB[:event_templates].order(:title).where(Sequel.|(Sequel.like(:title, "%#{capitalize_name}%"), Sequel.like(:title, "%#{lowercase_name}%") ) ).where(:status => status).each do |event_template_row|
      event_template = EventTemplate.from_hash(event_template_row)
      DB[:events].order(:title).where(:event_template_id => event_template_row[:id]).each do |event_row|
        event = Event.from_hash(event_row)
        if DB[:assigned_coaches].where(:event_id=> event_row[:id]) != []
          DB[:assigned_coaches].where(:event_id=> event_row[:id]).each do |assigned_coach_row|
            assigned_coach = AssignedCoach.from_hash(assigned_coach_row)
            DB[:coaches].order(:name).where(:id => assigned_coach.coach_id).each do |coach_row|
              coach = Coach.from_hash(coach_row)
              event.coaches_emails << coach.email
              event.assigned_coaches << coach
            end
          end
        end
        event_template.events << event
      end

      DB[:coach_fees].where(Sequel.&(:event_template_id => event_template_row[:id], :event_id => nil)).each do |coach_fee_row|
        coach_fee = CoachesFee.from_hash(coach_fee_row)
        event_template.coach_fees << coach_fee
      end

      templates << event_template
    end
    templates
  end

end
