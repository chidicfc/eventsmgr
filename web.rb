require "ostruct"
require "pry-remote"
require "date"
require "sinatra"
require "require_all"
require 'sinatra/flash'



require_all "app"


enable :sessions






before'/' do
  @view = IndexView.new
  @controller = IndexViewController.new(@view)
end

get '/' do
  if session[:status] = true
    @controller.load_default_coaches_fee
    @controller.display_templates
    erb :index

  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

get '/authenticating/:sso_id' do

  @sso_id = params[:sso_id]
  sso = Session.new(params[:sso_id])
  sso.broadcast

  erb :authenticating

end

post '/authenticated' do

  session[:sso_token] = params[:sso_token]
  session[:user_timezone] = params[:user_timezone]
  session[:status] = true

  redirect '/'
end

get '/dashboard' do

  session.clear
  redirect 'http://app.coachinabox.biz//dashboard'
end

get '/reset' do
  if session[:status] = true
    @controller = ResetTemplateController.new
    @controller.reset
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end


get '/event_template/:id/edit' do |n|
  if session[:status] = true
    @edit_template_view = EditEventTemplateView.new
    @edit_template_controller = EditEventTemplateViewController.new(@edit_template_view)
    @edit_template_controller.get n
    erb :edit_template
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
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
  if session[:status] = true
    @new_template_view = NewEventTemplateView.new
    @new_template_controller = NewEventTemplateViewController.new
    @new_template_controller.view = @new_template_view
    @new_template_view.selected_duration_hours = "01"
    @new_template_view.selected_duration_mins = "00"
    @new_template_controller.get_default_coach_fees
    erb :new_template
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end

end

post '/new_template' do

  count = params[:count].to_i
  array_fees = []
  for x in (0..count)
     array_fees << {"currency#{x}".to_sym => params["currency#{x}".to_sym], "amount#{x}".to_sym => params["amount#{x}".to_sym]}
  end
  new_template_controller = NewEventTemplateViewController.new
  duration = "#{params[:duration_hours]}:#{params[:duration_mins]}"

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

delete '/event_template/:id' do
  if session[:status] = true
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
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

patch '/event_template/:id' do

  result = ArchiveEventTemplateController.new.archive params[:id]

  if result
    flash[:success] = "Template archived!"
  else
    flash[:error] = "Can't archive an event template which has live events!"
  end

  redirect '/'
end

get '/show_archive' do
  if session[:status] = true
    @show_archive_view = ShowArchiveEventTemplateView.new
    @show_archive_controller = ShowArchiveEventTemplateController.new(@show_archive_view)
    @show_archive_controller.show
    erb :archive
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

patch '/archive_event_template/:id' do
  @view = ShowArchiveEventTemplateView.new
  @controller = ShowArchiveEventTemplateController.new(@view)
  @controller.unarchive params[:id]
  redirect '/' if @controller.show.empty?
  redirect '/show_archive'
end

get '/show_event_templates' do
  if session[:status] = true
    redirect '/'
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

get '/:template_id/new_event' do
  if session[:status] = true
    @view = NewEventView.new
    @new_event_controller = NewEventViewController.new(@view)
    @new_event_controller.get params[:template_id]

    if params[:action]=="new"
      session["event"] = nil
      @view.event.duration_hours = @view.template.duration.split(":")[0]
      @view.event.duration_mins = @view.template.duration.split(":")[1]
    end

    @view.event.start_hours = "09"
    @view.event.start_mins = "00"


    @view.event.selected_time_zone = session["user_timezone"].gsub('/', ' - ') if @view.event.selected_time_zone.nil?

    #@view.event.selected_time_zone = "Europe - London"
    @view.event.date = Time.now.strftime("%d/%m/%Y")

    if !(session["event"].nil?)
      @view.event = session["event"]
    end


    @new_event_controller.get_coaches
    @new_event_controller.get_cohorts
    @new_event_controller.get_timezones


    erb :new_event
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

post '/:template_id/new_event' do

  @new_event_view = NewEventView.from_params params, params[:template_id]


  @new_event_controller = NewEventViewController.new(@new_event_view)
  @new_event_controller.get_coaches
  @new_event_controller.get_cohorts
  @new_event_controller.get_timezones
  @new_event_controller.get params[:template_id]


  if params[:action] == ">"
    unless params[:coaches].nil?
      params["coaches"].each do |coach|
        @new_event_view.event.assigned_coaches << coach
      end

      if session["event"]
        NewEventView.set_assigned_coaches(@new_event_view, session["event"].assigned_coaches)
      end

      session["event"] = @new_event_view.event
      redirect "#{params[:template_id]}/new_event#coaches"

    else
      flash[:error] = "Please choose a coach"

      if session["event"]
        NewEventView.set_assigned_coaches(@new_event_view, session["event"].assigned_coaches)
      end

      session["event"] = @new_event_view.event
      redirect "#{params[:template_id]}/new_event"
    end


  elsif params[:action] == "<"
    unless params[:assigned_coaches].nil?

      @new_event_view.event.assigned_coaches = session["event"].assigned_coaches
      params["assigned_coaches"].each do |assigned_coach|
        @new_event_view.event.assigned_coaches.delete("#{assigned_coach}")
      end

      session["event"] = @new_event_view.event
      redirect "#{params[:template_id]}/new_event#coaches"

    else
      flash[:error] = "Please choose an assigned coach"

      @new_event_view.event.assigned_coaches = session["event"].assigned_coaches if session["event"]
      session["event"] = @new_event_view.event
      redirect "#{params[:template_id]}/new_event"
    end

  elsif params[:action] == "Reset"
    @new_event_view.event.assigned_coaches = []

    session["event"] = @new_event_view.event
    redirect "#{params[:template_id]}/new_event#coaches"

  elsif params[:action] == "Create Event"

    if @new_event_view.event.selected_cohort == "Please Choose"
      flash[:error] = "Please choose a cohort"
      @new_event_view.event.assigned_coaches = session["event"].assigned_coaches if session["event"].assigned_coaches
      session["event"] = @new_event_view.event
      redirect "#{params[:template_id]}/new_event"
    end


    if session["event"]

      @new_event_view.event.assigned_coaches = session["event"].assigned_coaches

      @new_event_controller.add_event @new_event_view.event

      assigned_coaches_ids = []
      @new_event_view.event.assigned_coaches.each do |assigned_coach_name|
        coach = @new_event_view.coaches.find { |coach| coach.name == assigned_coach_name }
        assigned_coaches_ids << coach.coach_id
      end

      @new_event_view.event.assigned_coaches = assigned_coaches_ids


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

    session["event"] = nil
    redirect '/'

  elsif params[:action] == "Show All"
    @new_event_view.event.assigned_coaches = session["event"].assigned_coaches

    session["event"] = @new_event_view.event
    redirect "#{params[:template_id]}/new_event#coaches"

  else
    for letter in [*'A'..'Z']
      if params[:action] == letter
        @new_event_view.event.assigned_coaches = session["event"].assigned_coaches if session["event"]
        @new_event_controller.display_coaches_by_letter letter
      end
    end

    session["event"] = @new_event_view.event
    redirect "#{params[:template_id]}/new_event#coaches"
  end


  # session["event"] = @new_event_view.event
  #
  # redirect "#{params[:template_id]}/new_event"
end


get '/event/:template_id/:event_id/edit' do

  if session[:status] = true
    @view = EditEventView.new
    @edit_event_controller = EditEventViewController.new(@view)

    if params[:action]=="new"
      session["event"] = nil
    end

    @edit_event_controller.get_event params[:template_id], params[:event_id] if session["event"].nil?

    @view.event = session["event"] unless session["event"].nil?
    @edit_event_controller.get_coaches
    @edit_event_controller.get_cohorts
    @edit_event_controller.get_timezones
    @edit_event_controller.get params[:template_id]

    session["event"] = @view.event


    erb :edit_event
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

post '/event/:template_id/:event_id/edit' do


  @view = EditEventViewController.from_params params, params[:template_id]


  @edit_event_controller = EditEventViewController.new(@view)

  @edit_event_controller.get_coaches
  @edit_event_controller.get_cohorts
  @edit_event_controller.get_timezones
  @edit_event_controller.get params[:template_id]


  if params[:action] == ">"
    unless params[:coaches].nil?
      params["coaches"].each do |coach|
        @view.event.assigned_coaches << coach
      end

      if session["event"]
        EditEventViewController.set_assigned_coaches(@view, session["event"].assigned_coaches)

      end

      session["event"] = @view.event

      redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit#coaches"
    else

      flash[:error] = "Please choose a coach"

      if session["event"]
        EditEventViewController.set_assigned_coaches(@view, session["event"].assigned_coaches)

      end

      session["event"] = @view.event
      redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit"

    end


  elsif params[:action] == "<"
    unless params[:assigned_coaches].nil?

      @view.event.assigned_coaches = session["event"].assigned_coaches
      params["assigned_coaches"].each do |assigned_coach|
        @view.event.assigned_coaches.delete("#{assigned_coach}")
      end

      session["event"] = @view.event
      redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit#coaches"
    else
      flash[:error] = "Please choose an assigned coach"
      @view.event.assigned_coaches = session["event"].assigned_coaches if session["event"]
      session["event"] = @view.event
      redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit"
    end

  elsif params[:action] == "Reset"
    @view.event.assigned_coaches = []

    session["event"] = @view.event
    redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit#coaches"

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


    @edit_event_controller.transmit_edited_event @view.event


    session["event"] = nil
    redirect '/'

  elsif params[:action] == "Show All"
    @view.event.assigned_coaches = session["event"].assigned_coaches

    session["event"] = @view.event
    redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit#coaches"

  elsif params[:action] == "Cancel"
    redirect '/'
  else
    for letter in [*'A'..'Z']
      if params[:action] == letter
        @view.event.assigned_coaches = session["event"].assigned_coaches
        @edit_event_controller.display_coaches_by_letter letter
      end
    end

    session["event"] = @view.event
    redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit#coaches"

  end



  # session["event"] = @view.event
  # redirect "event/#{params[:template_id]}/#{params[:event_id]}/edit"

end

get '/event/:template_id/:event_id/delete' do
  if session[:status] = true
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
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

get '/search_templates_by_letter/:letter' do
  if session[:status] = true
    @view = IndexView.new
    @controller = IndexViewController.new(@view)
    @controller.display_templates_by_letter params[:letter], "active"
    erb :index
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
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
  if session[:status] = true
    @show_archive_view = ShowArchiveEventTemplateView.new
    @controller = ShowArchiveEventTemplateController.new(@show_archive_view)
    @controller.display_templates_by_letter params[:letter], "archive"
    erb :archive
  else
    redirect 'http://app.coachinabox.biz//users/sign_in'
  end
end

post '/search_archive_templates_by_name' do
  if params[:action] == "GO"
    @show_archive_view = ShowArchiveEventTemplateView.new
    @controller = ShowArchiveEventTemplateController.new(@show_archive_view)
    @controller.search_templates_by_name params[:search], "archive"
    erb :archive
  end
end
