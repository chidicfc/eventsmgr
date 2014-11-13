class DeleteEventTemplateController

  def initialize
    @template_repo = EventTemplate::Repository.new
  end

  def delete id
    @template_repo.delete_template id
  end

end
