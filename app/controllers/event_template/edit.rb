class EditEventTemplateViewController
  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplateRepo.new
    @view = view
  end

  def split_time time
    time.split(":")
  end

  def get template_id
    @view.template = @template_repo.get template_id
    @view.template.duration = split_time @view.template.duration
  end

  def update *args
    @template_repo.update_template *args
  end
end
