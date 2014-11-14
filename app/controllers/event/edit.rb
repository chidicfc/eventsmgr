class EditEventViewController
  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplate::Repository.new
    @event_repo = Event::Repository.new
    @coach_repo = Coach::Repository.new
    @timezone_repo = TimeZone::Repository.new
    @cohort_repo = Cohort::Repository.new
    @view = view
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

  def get template_id
    @view.template = @template_repo.get template_id
  end

  def split_time time
    time.split(":")
  end

  def get_event template_id, event_id
    @view.event = @event_repo.get_event template_id, event_id
    @view.event.start_time = split_time @view.event.start_time
    @view.event.duration = split_time @view.event.duration
  end

  def self.from_params params, template_id

    view = EditEventView.new

    view.event.title = params["sub_title"]
    view.event.date = params["date"]
    view.event.description = params["description"]
    view.event.timezone = params["timezone"]
    view.event.cohort = params["cohort"]
    view.event.income_amount = params["income_amount"]
    view.event.income_currency = params["income_currency"]
    view.event.start_time = ["#{params[:start_hours]}","#{params[:start_mins]}"]
    view.event.duration = ["#{params[:duration_hours]}","#{params[:duration_mins]}"]



    @template_repo = EventTemplate::Repository.new
    view.template =  @template_repo.get template_id

    for coach_fee in view.template.coach_fees
      view.event.coach_fees << {"#{coach_fee.currency}" => params["#{coach_fee.currency}"]}
    end

    view
  end

  def self.set_assigned_coaches view, initial_assigned_coaches
    view.event.assigned_coaches.each do |assigned_coach|
      initial_assigned_coaches << assigned_coach
    end
    view.event.assigned_coaches = initial_assigned_coaches
    view.event.assigned_coaches.uniq!
  end

  def edit_event template_id, event_id, sub_title, duration, description, date, start_time, timezone, cohort, coach_fees, assigned_coaches, income_amount, income_currency
    @event_repo.edit_event template_id, event_id, sub_title, duration, description, date, start_time, timezone, cohort, coach_fees, assigned_coaches, income_amount, income_currency
  end

  def display_coaches_by_letter letter
    @view.event.searched_coaches = @coach_repo.search_coaches_by_letter letter
  end

end
