class IndexViewController
  attr_accessor :view

  def initialize(view)
    @view = view
    @template_repo = EventTemplate::Repository.new
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

  def load_default_coaches_fee
    @template_repo.load_default_coaches_fee
  end

end
