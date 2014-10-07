class ShowArchiveEventTemplateController
  attr_accessor :view

  def initialize(view=nil)
    @template_repo = EventTemplateRepo.new
    @view = view
  end

  def show
    @view.archive_templates = @template_repo.show_archive
  end

  def unarchive id
    @template_repo.unarchive_template id
  end

  def display_templates_by_letter letter, status
    @view.archive_templates = @template_repo.search_templates_by_letter letter, status
  end

  def search_templates_by_name name, status
    @view.archive_templates = @template_repo.search_templates_by_name name, status
  end

end
