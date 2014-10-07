class IndexViewController
  attr_accessor :view

  def initialize(view)
    @view = view
    @template_repo = EventTemplateRepo.new
  end

  def display_templates
    @view.templates = @template_repo.all
  end

  def display_templates_by_letter letter, status
    @view.templates = @template_repo.search_templates_by_letter letter, status
  end

  def search_templates_by_name name, status
    @view.templates = @template_repo.search_templates_by_name name, status
  end
end
