class AssignedCoach
    attr_accessor :id, :event_id, :coach_id

    def initialize (id, event_id, coach_id)
      @id = id
      @event_id = event_id
      @coach_id = coach_id
    end

    def self.from_hash(row)
      assigned_coach = AssignedCoach.new row[:id], row[:event_id], row[:coach_id]
      assigned_coach
    end

    class Repository

    end

end
