class NewEventViewController
  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplate::Repository.new
    @event_repo = Event::Repository.new
    @coach_repo = CoachRepo.new
    @timezone_repo = Timezone::Repository.new
    @cohort_repo = CohortRepo.new
    @view = view
  end

  def get template_id
    @view.template = @template_repo.get template_id
  end

  def get_coaches
    @view.coaches = @coach_repo.get_coaches
  end

  def get_timezones
    @view.timezones = @timezone_repo.get_timezones
  end

  def get_cohorts
    @view.cohorts = @cohort_repo.get_cohorts
  end

  def display_coaches_by_letter letter
    @view.event.searched_coaches = @coach_repo.search_coaches_by_letter letter
  end

  def add_event template_id, title, duration, description, start_date, start_time, timezone, cohort, coaches_fee, assigned_coaches, income_amount, income_currency
    @event_repo.add_event template_id, title, duration, description, start_date, start_time, timezone, cohort, coaches_fee, assigned_coaches, income_amount, income_currency
  end

end
