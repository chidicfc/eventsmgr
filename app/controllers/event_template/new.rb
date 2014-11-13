class NewEventTemplateViewController

  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplate::Repository.new
    @coach_fees_repo = CoachFeesRepo.new
    @view = view
  end

  def get_default_coach_fees
    @view.coach_fees = @coach_fees_repo.default_coach_fees
  end

  def save *args
    @template_repo.add *args
  end
end
