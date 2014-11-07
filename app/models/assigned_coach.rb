class AssignedCoach
    attr_accessor :name, :id, :event_id, :email, :image

    def initialize (id, name, email, image, event_id)
      @name = name
      @email = email
      @image = image
      @id = id
      @event_id = event_id
    end

    def self.from_hash(row)
      assigned_coach = AssignedCoach.new row[:id], row[:name], row[:email], row[:image], row[:event_id]
      assigned_coach
    end

end
