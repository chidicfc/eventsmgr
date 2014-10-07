class EventTemplate

  attr_accessor :title, :duration, :description
  attr_accessor :events, :coach_fees, :id, :status

  def initialize()
    @events = []
    @coach_fees = []
  end

  def self.from_hash(row)
    template = EventTemplate.new
    template.id = row[:id]
    template.title = row[:title]
    template.duration =row[:duration]
    template.description =row[:description]
    template.status = row[:status]
    template
  end

end
