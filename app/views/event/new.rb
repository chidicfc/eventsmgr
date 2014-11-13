class NewEventView
  attr_accessor :coaches, :timezones, :cohorts
  attr_accessor :template, :coach_fees,:event


  def initialize
    @coaches = []
    @timezones = []
    @cohorts = []
    @coach_fees = []
    @event = OpenStruct.new
    @event.coach_fees = []
    @event.assigned_coaches = []
    @template_repo = EventTemplate::Repository.new
  end

  def self.from_params params, template_id

    view = NewEventView.new
    view.event.event_template_id = params["template_id"]
    view.event.title = params["sub_title"]
    view.event.date = params["date"]
    view.event.description = params["description"]
    view.event.start_hours = params["start_hours"]
    view.event.start_mins = params["start_mins"]
    view.event.duration_hours = params["duration_hours"]
    view.event.duration_mins = params["duration_mins"]
    view.event.duration = "#{params["duration_hours"]}:#{params["duration_mins"]}"
    view.event.start_time = "#{params["start_hours"]}:#{params["start_mins"]}"
    view.event.selected_time_zone = params["timezone"]
    view.event.selected_cohort = params["cohort"]
    view.event.income_amount = params["income_amount"]
    view.event.selected_income_currency = params["income_currency"]


    @template_repo = EventTemplate::Repository.new
    view.template =  @template_repo.get template_id

    # @coach_repo = Cohort::Repository.new
    # view.searched_coaches = @coach_repo.

  for coach_fee in view.template.coach_fees
    view.event.coach_fees << {"#{coach_fee.currency}" => params["#{coach_fee.currency}"]}
  end

    view
  end

  def self.set_assigned_coaches view, initial_assigned_coaches
    view.event.assigned_coaches.each do |assigned_coaches|
      initial_assigned_coaches << assigned_coaches
    end
    view.event.assigned_coaches = initial_assigned_coaches
    view.event.assigned_coaches.uniq!
  end

  def has_coach_fee? name
    @event.coach_fees.has_key? name
  end

  def get_coach_fee_for name
    @event.coach_fees[name]
  end

end
