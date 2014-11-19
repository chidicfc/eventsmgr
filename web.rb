require "ostruct"
require "pry-remote"
require "date"
require "sinatra"
require "require_all"
require 'sinatra/flash'



require_all "app"


enable :sessions

# configure do
#   # logging is enabled by default in classic style applications,
#   # so `enable :logging` is not needed
#   file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
#   file.sync = true
#   use Rack::CommonLogger, file
# end



before'/' do
  @view = IndexView.new
  @controller = IndexViewController.new(@view)
  @controller.load_default_coaches_fee
  @controller.display_templates
end

get '/' do
  @controller.display_templates
  erb :index
end

get '/reset' do
  @controller = ResetTemplateController.new
  @controller.reset
end


get '/event_template/:id/edit' do |n|
  @edit_template_view = EditEventTemplateView.new
  @edit_template_controller = EditEventTemplateViewController.new(@edit_template_view)
  @edit_template_controller.get n
  erb :edit_template
end

patch '/edit_template/:id' do

  if params[:action] == "Cancel"
    redirect '/'
  elsif params[:action] == "Edit Template"
    count = params[:count].to_i
    id = params[:id].to_i
    array_fees = []
    for x in (0..count)
       array_fees << {"currency#{x}".to_sym => params["currency#{x}".to_sym], "amount#{x}".to_sym => params["amount#{x}".to_sym]}
    end
    edit_template_controller = EditEventTemplateViewController.new
    duration = "#{params[:duration_hours]}:#{params[:duration_mins]}"
    edit_template_controller.update params[:id], params[:title], duration, array_fees, params[:description]
    edit_template_controller.transmit_updated_template params[:id]


    redirect '/'
  end
end

get '/new_template' do

  @new_template_view = NewEventTemplateView.new
  @new_template_controller = NewEventTemplateViewController.new
  @new_template_controller.view = @new_template_view
  @new_template_controller.get_default_coach_fees
  erb :new_template

end

post '/new_template' do

  if params[:action]=="Cancel"
    redirect '/'
  elsif params[:action] = "Create Template"
    count = params[:count].to_i
    array_fees = []
    for x in (0..count)
       array_fees << {"currency#{x}".to_sym => params["currency#{x}".to_sym], "amount#{x}".to_sym => params["amount#{x}".to_sym]}
    end
    new_template_controller = NewEventTemplateViewController.new
    duration = "#{params[:duration_hours]}:#{params[:duration_mins]}"

    #id = SecureRandom.uuid

    template = EventTemplate.new
    template.title = params[:title]
    template.duration = duration
    template.coach_fees = array_fees
    template.description = params[:description]

    new_template_controller.save template
    #new_template_controller.save params[:title], duration, array_fees, params[:description], id

    new_template_controller.transmit_new_template template

    redirect '/'

  end
end

delete '/event_template/:id' do

  # params.to_s
  template = DeleteEventTemplateController.new.get params[:id]

  result = DeleteEventTemplateController.new.delete params[:id]

  if result
    flash[:success] = "#{template.title} template deleted!"
  else
    flash[:error] = "Templates with events can't be deleted!"
  end

  DeleteEventTemplateController.new.transmit_deleted_template template
  redirect '/'
end

patch '/event_template/:id' do

  ArchiveEventTemplateController.new.archive params[:id]
  redirect '/'
end

get '/show_archive' do
  @show_archive_view = ShowArchiveEventTemplateView.new
  @show_archive_controller = ShowArchiveEventTemplateController.new(@show_archive_view)
  @show_archive_controller.show
  erb :archive
end

patch '/archive_event_template/:id' do
  @controller = ShowArchiveEventTemplateController.new
  @controller.unarchive params[:id]
  redirect '/show_archive'
end

get '/show_event_templates' do
  redirect '/'
end

get '/:template_id/new_event' do

  @view = NewEventView.new

  if params[:action]=="new"
    session.clear
  end

  @view.event.start_hours = "09"
  @view.event.start_mins = "00"
  @view.event.date = Time.now.strftime("%d/%m/%Y")

  if session.has_key? "event"
    @view.event = session["event"]
  end

  @new_event_controller = NewEventViewController.new(@view)
  @new_event_controller.get_coaches
  @new_event_controller.get_cohorts
  @new_event_controller.get_timezones
  @new_event_controller.get params[:template_id]

  erb :new_event
end

post '/:template_id/new_event' do

  @new_event_view = NewEventView.from_params params, params[:template_id]

  @new_event_controller = NewEventViewController.new(@new_event_view)
  @new_event_controller.get_coaches
  @new_event_controller.get_cohorts
  @new_event_controller.get_timezones
  @new_event_controller.get params[:template_id]


  if params[:action] == ">"
    params["coaches"].each do |coach|
      @new_event_view.event.assigned_coaches << coach
    end

    if session["event"]
      NewEventView.set_assigned_coaches(@new_event_view, session["event"].assigned_coaches)
    end


  elsif params[:action] == "<"
    @new_event_view.event.assigned_coaches = session["event"].assigned_coaches
    params["assigned_coaches"].each do |assigned_coach|
      @new_event_view.event.assigned_coaches.delete("#{assigned_coach}")
    end

  elsif params[:action] == "Reset"
    @new_event_view.event.assigned_coaches = []

  elsif params[:action] == "Create Event"

    # duration = "#{params[:duration_hours]}:#{params[:duration_mins]}"
    # start_time = "#{params[:start_hours]}:#{params[:start_mins]}"

    if session["event"]

      @new_event_view.event.assigned_coaches = session["event"].assigned_coaches

      @new_event_controller.add_event @new_event_view.event

      assigned_coaches_ids = []
      @new_event_view.event.assigned_coaches.each do |assigned_coach_name|
        coach = @new_event_view.coaches.find { |coach| coach.name == assigned_coach_name }
        assigned_coaches_ids << coach.coach_id
      end

      @new_event_view.event.assigned_coaches = assigned_coaches_ids

      cohort = @new_event_view.cohorts.find { |cohort| cohort.name == @new_event_view.event.selected_cohort }
      @new_event_view.event.selected_cohort = cohort.id


      @new_event_controller.transmit_new_event @new_event_view.event
    else
      @new_event_controller.add_event @new_event_view.event

      assigned_coaches_ids = []
      @new_event_view.event.assigned_coaches.each do |assigned_coach_name|
        coach = @new_event_view.coaches.find { |coach| coach.name == assigned_coach_name }
        assigned_coaches_ids << coach.coach_id
      end

      @new_event_view.event.assigned_coaches = assigned_coaches_ids

      cohort = @new_event_view.cohorts.find { |cohort| cohort.name == @new_event_view.event.selected_cohort }
      @new_event_view.event.selected_cohort = cohort.id

      @new_event_controller.transmit_new_event @new_event_view.event

    end

    session.clear
    redirect '/'

  elsif params[:action] == "Show All"
    @new_event_view.event.assigned_coaches = session["event"].assigned_coaches
  elsif params[:action] == "Cancel"
    redirect '/'
  else
    for letter in [*'A'..'Z']
      if params[:action] == letter
        @new_event_view.event.assigned_coaches = session["event"].assigned_coaches if session["event"]
        @new_event_controller.display_coaches_by_letter letter
      end
    end
  end


  session["event"] = @new_event_view.event

  redirect "#{params[:template_id]}/new_event"
end


get '/event/:template_id/:event_id/edit' do

  @view = EditEventView.new
  @edit_event_controller = EditEventViewController.new(@view)

  if params[:action]=="new"
    session.clear
  end

  @edit_event_controller.get_event params[:template_id], params[:event_id] unless session.has_key? "event"
  @view.event = session["event"] if session.has_key? "event"
  @edit_event_controller.get_coaches
  @edit_event_controller.get_cohorts
  @edit_event_controller.get_timezones
  @edit_event_controller.get params[:template_id]

  session["event"] = @view.event
  erb :edit_event
end

post '/event/:template_id/:event_id/edit' do


  @view = EditEventViewController.from_params params, params[:template_id]

  @edit_event_controller = EditEventViewController.new(@view)

  @edit_event_controller.get_coaches
  @edit_event_controller.get_cohorts
  @edit_event_controller.get_timezones
  @edit_event_controller.get params[:template_id]


  if params[:action] == ">"
    params["coaches"].each do |coach|
      @view.event.assigned_coaches << coach
    end

    if session["event"]
      EditEventViewController.set_assigned_coaches(@view, session["event"].assigned_coaches)

    end


  elsif params[:action] == "<"
    @view.event.assigned_coaches = session["event"].assigned_coaches
    params["assigned_coaches"].each do |assigned_coach|
      @view.event.assigned_coaches.delete("#{assigned_coach}")
    end

  elsif params[:action] == "Reset"
    @view.event.assigned_coaches = []

  elsif params[:action] == "Edit Event"

    duration = "#{params[:duration_hours]}:#{params[:duration_mins]}"
    start_time = "#{params[:start_hours]}:#{params[:start_mins]}"
    coach_fees = []
    for coach_fee in @view.template.coach_fees
      coach_fees << {"#{coach_fee.currency}" => params["#{coach_fee.currency}".to_sym]}
    end
    @view.event.assigned_coaches = session["event"].assigned_coaches
    @view.event.coach_fees = coach_fees

    @edit_event_controller.edit_event @view.event

    assigned_coaches_ids = []
    @view.event.assigned_coaches.each do |assigned_coach_name|
      coach = @view.coaches.find { |coach| coach.name == assigned_coach_name }
      assigned_coaches_ids << coach.coach_id
    end

    @view.event.assigned_coaches = assigned_coaches_ids

    cohort = @view.cohorts.find { |cohort| cohort.name == @view.event.selected_cohort }
    @view.event.selected_cohort = cohort.id
    @edit_event_controller.transmit_edited_event @view.event


    session.clear
    redirect '/'

  elsif params[:action] == "Show All"
    @view.event.assigned_coaches = session["event"].assigned_coaches
  elsif params[:action] == "Cancel"
    redirect '/'
  else
    for letter in [*'A'..'Z']
      if params[:action] == letter
        @view.event.assigned_coaches = session["event"].assigned_coaches
        @edit_event_controller.display_coaches_by_letter letter
      end
    end
  end



  session["event"] = @view.event


  redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit"

end

get '/event/:template_id/:event_id/delete' do
  @view = DeleteEventView.new
  @controller = DeleteEventController.new(@view)

  @controller.get_event params[:template_id], params[:event_id]

  if @view.event.assigned_coaches.count == 0
    event = @view.event
    @controller.get_cohorts
    @controller.delete params[:event_id], params[:template_id]
    flash[:success] = "#{event.title} Event deleted!"

    cohort = @view.cohorts.find { |cohort| cohort.name == event.selected_cohort }
    event.selected_cohort = cohort.id

    @controller.transmit_deleted_event event
  else
    flash[:error] = "Events with coaches can't be deleted!"
  end

  redirect '/'
end

get '/search_templates_by_letter/:letter' do
  @view = IndexView.new
  @controller = IndexViewController.new(@view)
  @controller.display_templates_by_letter params[:letter], "active"
  erb :index
end

post '/search_templates_by_name' do
  if params[:action] == "GO"
    @view = IndexView.new
    @controller = IndexViewController.new(@view)
    @controller.search_templates_by_name params[:search], "active"

    erb :index
  end
end

get '/search_archive_templates_by_letter/:letter' do
  @show_archive_view = ShowArchiveEventTemplateView.new
  @controller = ShowArchiveEventTemplateController.new(@show_archive_view)
  @controller.display_templates_by_letter params[:letter], "archive"
  erb :archive
end

post '/search_archive_templates_by_name' do
  if params[:action] == "GO"
    @show_archive_view = ShowArchiveEventTemplateView.new
    @controller = ShowArchiveEventTemplateController.new(@show_archive_view)
    @controller.search_templates_by_name params[:search], "archive"
    erb :archive
  end
end
