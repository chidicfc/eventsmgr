class CoachesFee
  attr_accessor :currency, :amount, :template_id, :event_id, :id

  def initialize(currency, amount, template_id)
    @currency = currency
    @amount = amount
    @template_id = template_id
  end

  def self.from_hash(row)
    coach_fee = CoachesFee.new row[:currency],row[:amount],row[:event_template_id]
    coach_fee.event_id = row[:event_id]
    coach_fee.id = row[:id]
    coach_fee
  end

  class Repository

    def initialize
      @datastore = DataBaseDataStore.new
    end

    def default_coach_fees
      @datastore.default_coach_fees
    end

  end

end
