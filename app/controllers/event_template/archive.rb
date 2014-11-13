class ArchiveEventTemplateController

  def initialize
    @template_repo = EventTemplate::Repository.new
  end

  def archive id
    @template_repo.archive_template id
  end
end
