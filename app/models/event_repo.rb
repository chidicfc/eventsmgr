class EventRepo

  def initialize
    @datastore = DataBaseDataStore.new
  end

  def add_event template_id, title, duration, description, start_date, start_time, timezone, cohort, coaches_fee, assigned_coaches, income_amount, income_currency
    @datastore.add_event template_id, title, duration, description, start_date, start_time, timezone, cohort, coaches_fee, assigned_coaches, income_amount, income_currency
  end

  def get_event template_id, event_id
    @datastore.get_event template_id, event_id
  end

  def edit_event template_id, event_id, sub_title, duration, description, date, start_time, timezone, cohort, coach_fees, assigned_coaches, income_amount, income_currency
    @datastore.update_event template_id, event_id, sub_title, duration, description, date, start_time, timezone, cohort, coach_fees, assigned_coaches, income_amount, income_currency
  end

  def delete_event event_id, template_id
    @datastore.delete_event event_id, template_id
  end

end
