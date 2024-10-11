# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MATRIX MODULE
# -----------------------------------------------------------------------------------------

# renders the main matrix frame
get '/matrix' do
  partial :"frame/matrix"
end

# -----------------------------------------------------------------------------------------
# SCHEDULES
# -----------------------------------------------------------------------------------------

get '/matrix/schedule/table' do
	@objects = Schedule.get_all
	partial :"table/matrix/schedule"
end

get '/matrix/schedule/:id' do
	@object = (params[:id]=="new" ? nil : (Schedule.find params[:id]))
	partial :"form/matrix/schedule"
end

post '/matrix/schedule/:id' do
	schedule = Schedule.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" 	then (schedule==nil ? (Schedule.create params ): (schedule.update params))
		when "delete" then schedule.destroy
	end
	redirect :"/matrix"
end

# -----------------------------------------------------------------------------------------
# TASKS
# -----------------------------------------------------------------------------------------

get '/matrix/task/table' do
	@objects = Task.all
	partial :"table/matrix/task"
end

get '/matrix/task/:id' do
	@object = (params[:id]=="new" ? Task.create_default : (Task.find params[:id]))
	@task_schedules = TaskSchedule.includes(:schedule).where(task: @object)
	partial :"form/matrix/task"
end

post '/matrix/task/:id' do
	task = Task.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" then (task==nil ? (Task.create params): (task.update params))
		when "delete" then task.destroy
	end
	redirect '/matrix'
end

# Validates if the params received are valid for updating or creating a task object.
# returns a JSON object of the form {result: boolean, message: string}
post '/matrix/task/:id/validate' do
	content_type :json
	(Task.validate params).to_json
end

# -----------------------------------------------------------------------------------------
# SITUATIONS
# -----------------------------------------------------------------------------------------

get '/matrix/situation/table' do
	@objects = Situation.all
	partial :"table/matrix/situation"
end

get '/matrix/situation/:id' do
	@object = (params[:id]=="new" ? nil : (Situation.find params[:id]))
	partial :"form/matrix/situation"
end

post '/matrix/situation/:id' do
	situation = Situation.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" 	then (situation==nil ? (Situation.create params ): (situation.update params))
		when "delete" then situation.destroy
	end
	redirect :"/matrix"
end


# -----------------------------------------------------------------------------------------
# PERIODS
# -----------------------------------------------------------------------------------------

get '/matrix/period/table' do
	@objects = Period.all.order(s_date: :desc)
	partial :"table/matrix/period"
end

get '/matrix/period/:id' do
	@object = (params[:id]=="new" ? nil : Period.find(params[:id]))
	partial :"form/matrix/period"
end

post '/matrix/period/:id' do
	period = Period.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" then (period==nil ? (Period.create params ): (period.update params))
		when "delete" then period.destroy
	end
	redirect :"/matrix"
end

# Shows one week of the the assignments table for the period.
get '/matrix/period/:id/task_assignment/table' do
	@period_id = params[:id].to_i
	@week = (params[:week]=nil? ? 1 : params[:week].to_i)
	@period = Period.find(params[:id])
	@day_schedules = @object.get_week @week
	partial :"table/matrix/task_assignment"
end

# -----------------------------------------------------------------------------------------
# DAY SCHEDULES
# -----------------------------------------------------------------------------------------

get '/matrix/day_schedule/:id/update' do
	@object = DaySchedule.find(params[:id])
	schedule = Schedule.find(params[:schedule])
	@object.update(schedule: schedule)
	{result: true}.to_json
end

get '/matrix/day_schedule/:id' do
	@object = (params[:id]=="new" ? nil : DaySchedule.includes(:schedule).find(params[:id]))
	partial :"form/matrix/day_schedule"
end

post '/matrix/day_schedule/:id' do
	@object = DaySchedule.find(params[:id])
	params["task"].keys.each do |key|
		task = Task.find key
		day_schedule = @object
		people =  params["task"][key].blank? ? nil : Person.find(params["task"][key].values)
		TaskAssignment.assign task, day_schedule, people
	end
	redirect "/matrix/period/#{@object.period.id}"
end



# updates the schedule type of a specific day schedule. It is called via a script so therefore
# there is no need to return a view.
post '/matrix/day_schedule/:ds/schedule/:schedule' do
	ds = DaySchedule.find params[:ds]
	schedule = Schedule.find params[:schedule]
	ds.update(schedule: schedule)
end


get '/matrix/period/:id/assign' do
	Period.find(params[:id]).assign_all_tasks
	redirect "/matrix/period/#{params[:id]}/task_assignment/table?week=1"
end

get '/matrix/day_schedule/:id/task_assignments' do
	@object = (params[:id]=="new" ? nil : DaySchedule.includes(:schedule).find(params[:id]))
	partial :"form/matrix/task_assignments"
end

get '/matrix/people_modal/empty' do
	partial :"table/matrix/people_modal_empty"
end

get '/matrix/people_periods/table' do
	@objects = PersonPeriod.includes(:person).all.order("people.family_name")
	partial :"table/matrix/people_periods"
end

get '/matrix/people_periods/table/search' do
	@objects = PersonPeriod.joins(:person).where("people.short_name ILIKE '%#{params[:q]}%'")
	partial :"table/matrix/people_periods"
end

get '/matrix/people_periods' do
	partial :"frame/people_periods"
end

get '/matrix/person_period/:id' do
	@object = (params[:id]=="new" ? nil : PersonPeriod.find(params[:id]))
	@ta = @object.nil? ? nil : @object.tasks_available.pluck(:task_id)
	@availability = @object.nil? ? nil : @object.days_available.order(day: :asc)
	puts "availability #{@availability.inspect}"
	partial :"form/matrix/person_period"
end

post '/matrix/person_period/:id' do
	person = Person.find params[:person]
	if params[:id]=="new"
		PersonPeriod.create params
	else
		pp = PersonPeriod.find(params[:id])
		pp.destroy if (params[:commit]=="delete" && !pp.nil?)
		pp.update params if (params[:commit]=="save" && !pp.nil?)
	end
	partial :"frame/people_periods"
end

# renders a modal with a list of the people available for a task with a specific day schedule
get '/matrix/people_modal/ds/:ds/task/:task' do
	@ds  = DaySchedule.find params[:ds]
	@period = @ds.period
	@task  = Task.find params[:task]
	@task_schedule = TaskSchedule.find_task_schedule @task, @ds
	@selected_people  = @ds.get_assigned_people @task
	@available_people = PersonPeriod.find_people_available @ds, @task
	#@available_people = available_people_hash.map{|ph| ph[:id] }
	#@available_people_times = @available_people.map{|person| @period.get_assignments_time(person) }
	@available_people.concat(@selected_people) unless @selected_people.nil?
	partial :"table/matrix/people_modal"
end

get '/matrix/ds/:ds/task/:task' do
	@task  = Task.find params[:task]
	@ds  = DaySchedule.find params[:ds]
	partial :"table/matrix/day_schedule_cell"
end

get '/matrix/ds/:ds/task/:task/person/:person/:action' do
	@task  = Task.find params[:task]
	@ds  = DaySchedule.find params[:ds]
	@person = Person.find params[:person]
	@task_schedule = TaskSchedule.find_task_schedule @task, @ds
	case params[:action]
		when "add" then TaskAssignment.create(day_schedule: @ds, task_schedule: @task_schedule, person: @person )
		when "remove" then TaskAssignment.find_by(day_schedule: @ds, task_schedule: @task_schedule, person: @person).destroy
	end
	pp = PeriodPoint.find_by(person: @person, period: @ds.period)
	pp = PeriodPoint.create(person: @person, period: @ds.period) if pp.nil?
	pp.update_points
	partial :"table/matrix/day_schedule_cell"
end
