class Coach
  attr_accessor :name, :email, :coach_id, :image

  def initialize (coach_id, name, email, image)
    @name = name
    @email = email
    @coach_id = coach_id
    @image = image
  end

  def self.from_hash(row)
    coach = Coach.new(row[:id], row[:name], row[:email], row[:image])
    coach
  end

  class Repository

    def initialize
      @datastore = DataBaseDataStore.new
    end

    def get_coaches
      @datastore.get_coaches
    end

    def search_coaches_by_letter letter
      @datastore.search_coaches_by_letter letter
    end

    def get_coach id
      @datastore.get_coach id
    end

  end

end
