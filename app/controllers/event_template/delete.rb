class DeleteEventTemplateController

  def initialize
    @template_repo = EventTemplateRepo.new
  end

  def delete id
    @template_repo.delete_template id
  end

end
