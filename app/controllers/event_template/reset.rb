class ResetTemplateController
  attr_accessor :repo

  def initialize
    @repo = EventTemplateRepo.new
  end

  def reset
    @repo.reset_db
  end


end
