class CoachFee
  attr_accessor :currency, :amount, :template_id, :event_id, :id

  def initialize(currency, amount, template_id)
    @currency = currency
    @amount = amount
    @template_id = template_id
  end

  def self.from_hash(row)
    coach_fee = CoachFee.new row[:currency],row[:amount],row[:event_template_id]
    coach_fee.event_id = row[:event_id]
    coach_fee.id = row[:id]
    coach_fee
  end

end
