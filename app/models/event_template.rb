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

  class Repository
    def initialize
      @datastore = DataBaseDataStore.new
    end

    def all
      @datastore.all_templates
    end

    def add *args
      @datastore.add *args
    end

    def get template_id
      @datastore.get template_id
    end

    def update_template *args
      @datastore.update_template *args
    end

    def delete_template id
      @datastore.delete_template id
    end

    def archive_template id
      @datastore.archive_template id
    end

    def show_archive
      @datastore.show_archive
    end

    def unarchive_template id
      @datastore.unarchive_template id
    end

    def search_templates_by_letter letter, status
      @datastore.search_templates_by_letter letter, status
    end

    def search_templates_by_name name, status
      @datastore.search_templates_by_name name, status
    end

    def reset_db
      @datastore.reset_db
    end

    def load_default_coaches_fee
      @datastore.load_default_coach_fees
    end



  end

end
