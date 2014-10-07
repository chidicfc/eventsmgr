class EditEventView
  attr_accessor :coaches, :timezones, :cohorts, :start_time, :duration
  attr_accessor :template, :coach_fees,:event


  def initialize
    @coaches = []
    @timezones = []
    @cohorts = []
    @coach_fees = []
    @start_time = []
    @duration = []
    @event = OpenStruct.new
    @event.coach_fees = []
    @event.assigned_coaches = []
  end


end
