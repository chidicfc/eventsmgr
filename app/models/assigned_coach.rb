class AssignedCoach
    attr_accessor :name, :id, :event_id

    def initialize (id, name, event_id)
      @name = name
      @id = id
      @event_id = event_id
    end

    def self.from_hash(row)
      assigned_coach = AssignedCoach.new row[:id], row[:name], row[:event_id]
      assigned_coach
    end

end
