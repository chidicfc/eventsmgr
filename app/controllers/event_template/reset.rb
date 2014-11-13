class ResetTemplateController
  attr_accessor :repo

  def initialize
    @repo = EventTemplate::Repository.new
  end

  def reset
    @repo.reset_db
  end


end
