class DeleteEventView
  attr_accessor :event, :cohorts

  def initialize
    @event = OpenStruct.new
    @cohorts = []
  end


end
