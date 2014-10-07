class DeleteEventController
  attr_accessor :view

  def initialize(view=nil)
    @event_repo = EventRepo.new
    @view = view
  end

  def get_event template_id, event_id
    @view.event = @event_repo.get_event template_id, event_id
  end

  def delete event_id, template_id
    @event_repo.delete_event event_id, template_id
  end

end
