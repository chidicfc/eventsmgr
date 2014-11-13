class Cohort

  attr_accessor :name, :id

  def initialize(name)
    @name = name
  end

  def self.from_hash(row)
    cohort = Cohort.new(row[:name])
    cohort.id = row[:id]
    cohort
  end

  class Repository

    def initialize
      @datastore = DataBaseDataStore.new
    end

    def get_cohorts
      @datastore.get_cohorts
    end

  end

end
