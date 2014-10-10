require_relative "../db"

class CoachInABoxOs


  def load_coaches
    dataset = DB[:coaches]
    dataset.insert(:name => "Cheryl Jackson", :email => "xx@yahoo.com")
    dataset.insert(:name => "Tom Green", :email => "aa@yahoo.com")
    dataset.insert(:name => "Matt Taylor", :email => "bb@yahoo.com")
    dataset.insert(:name => "David Platt", :email => "cc@yahoo.com")
    dataset.insert(:name => "Michael Jackson", :email => "dd@yahoo.com")
    dataset.insert(:name => "Drew Black", :email => "ee@yahoo.com")
    dataset.insert(:name => "Neptunes", :email => "neptune@yahoo.com")
    dataset.insert(:name => "Mike Tello", :email => "tello@yahoo.com")
    dataset.insert(:name => "Janet Jackson", :email => "janet@yahoo.com")
    dataset.insert(:name => "Phil Jackson", :email => "phil@yahoo.com")
  end

  def load_cohorts
    dataset = DB[:cohorts]
    dataset.insert(:name => "2020 Project A Cohort B")
    dataset.insert(:name => "2019 Project A Cohort B")
    dataset.insert(:name => "Honda Project A Cohort B")
    dataset.insert(:name => "Apple North America Cohort B")
    dataset.insert(:name => "1999 Project B Cohort A")
    dataset.insert(:name => "Microsoft A Cohort B")
    dataset.insert(:name => "Mars Cohort A")
    dataset.insert(:name => "2000 Project A Cohort B")
    dataset.insert(:name => "Cadbury Project C Cohort B")
    dataset.insert(:name => "Unilever Project A Cohort B")
  end

  def load_timezones
    dataset = DB[:timezones]
    dataset.insert(:name => "(GMT+00.00) + London")
    dataset.insert(:name => "(GMT+00.00) + Europe/London")
    dataset.insert(:name => "(GMT+10.00) + Sydney")
    dataset.insert(:name => "(GMT+8.00) + Singapore")
    dataset.insert(:name => "(GMT+8.00) + Beijing")
    dataset.insert(:name => "(GMT+6.00) + Central America")
    dataset.insert(:name => "(GMT-11.00) + Hawaii")
    dataset.insert(:name => "(GMT-9.00) + Alaska")
    dataset.insert(:name => "(GMT-7.00) + Arizona")
    dataset.insert(:name => "(GMT-5.00) + Lima")
  end

  def get_coaches
    coaches = []
    DB[:coaches].each do |coach_row|
      coach = Coach.from_hash(coach_row)
      coaches << coach
    end
    coaches
  end


  def search_coaches_by_letter letter
    coaches = []
    DB[:coaches].where(Sequel.like(:name, "#{letter}%")).each do |coach_row|
      coach = Coach.from_hash(coach_row)
      coaches << coach
    end
    coaches
  end

  def get_timezones
    timezones = []
    DB[:timezones].each do |timezone_row|
      timezone = TimeZone.from_hash(timezone_row)
      timezones << timezone
    end
    timezones
  end

  def get_cohorts
    cohorts = []
    DB[:cohorts].each do |cohort_row|
      cohort = Cohort.from_hash(cohort_row)
      cohorts << cohort
    end
    cohorts
  end

  def update_calendar

  end

end
