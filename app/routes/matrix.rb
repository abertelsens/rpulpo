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
	@object = (params[:id]=="new" ? nil : Schedule.find(params[:id]))
	partial :"form/matrix/schedule"
end

post '/matrix/schedule/:id' do
	case params[:commit]
		when "save" then Schedule.create_update params
		when "delete" then Schedule.destroy params
	end
	redirect :"/matrix"
end

# updates the schedule type of a specific day schedule. It is called via a script so therefore
# there is no need to return a view.
post '/matrix/day_schedule/:ds/schedule/:schedule' do
	ds = DaySchedule.find(params[:ds])
	schedule = Schedule.find(params[:schedule])
end

# -----------------------------------------------------------------------------------------
# TASKS
# -----------------------------------------------------------------------------------------

get '/matrix/task/table' do
	@objects = Task.all.order(name: :asc)
	partial :"table/matrix/task"
end

get '/matrix/task/:id' do
	@object = (params[:id]=="new" ? nil : Task.find(params[:id]))
	partial :"form/matrix/task"
end

post '/matrix/task/:id' do
	case params[:commit]
	when "save" then Task.create_update params
	when "delete" then Task.destroy Task.find(params[:id])
	end
	redirect :"/matrix"
end


get '/matrix/task_schedule/table' do
	@objects = TaskSchedule.all.order(task_id: :asc)
	partial :"table/matrix/task_schedule"
end

get '/matrix/task_schedule/:id' do
	@object = (params[:id]=="new" ? nil : TaskSchedule.find(params[:id]))
	partial :"form/matrix/task_schedule"
end

post '/matrix/task_schedule/:id' do
	@task_schedule = (params[:id]=="new" ? nil : TaskSchedule.find(params[:id]))
	case params[:commit]
	when "save"
		if @task_schedule.nil?
			@task_schedule = TaskSchedule.create(TaskSchedule.prepare_params params)
		else
			@task_schedule.update(TaskSchedule.prepare_params params)
		end
	when "delete"
			@task_schedule.destroy
	end
	redirect :"/matrix"
end

get '/matrix/period/table' do
	@objects = Period.all.order(s_date: :desc)
	partial :"table/matrix/period"
end

get '/matrix/period/:id' do
	@object = (params[:id]=="new" ? nil : Period.find(params[:id]))
	partial :"form/matrix/period"
end

post '/matrix/period/:id' do
	@period = (params[:id]=="new" ? nil : Period.find(params[:id]))
	case params[:commit]
	when "save"
		if @period.nil?
			@period = Period.create(Period.prepare_params params)
			@period.create_days
		else
			@period.update(Period.prepare_params params)
		end
	when "delete"
			@period.destroy
	end
	redirect :"/matrix"
end

get '/matrix/period/:id/task_assignment/table' do
	@period_id = params[:id].to_i
	@week = (params[:week]=nil? ? 1 : params[:week].to_i)
	@object = (params[:id]=="new" ? nil : Period.find(params[:id]))
	@day_schedules = @object.get_week @week
	return if @day_schedules.nil?
	partial :"table/matrix/task_assignment"
end

get '/matrix/day_schedule/:id/update' do
	@object = DaySchedule.find(params[:id])
	puts Rainbow("got params #{params}").purple
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
	puts Rainbow("got params #{params}").purple
	params["task"].keys.each do |key|
		task = Task.find(key)
		day_schedule = @object
		people =  params["task"][key].blank? ? nil : Person.find(params["task"][key].values)
		TaskAssignment.assign(task, day_schedule, people)
	end
	redirect "/matrix/period/#{@object.period.id}"
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
	@objects = PersonPeriod.includes(:person).all
	partial :"table/matrix/people_periods"
end

get '/matrix/people_periods' do
	partial :"frame/people_periods"
end

get '/matrix/person_period/:id' do
	@object = (params[:id]=="new" ? nil : PersonPeriod.find(params[:id]))
	partial :"form/matrix/person_period"
end

post '/matrix/person_period/:id' do
	person = Person.find(params[:person])
	puts "posting a new period for #{person.short_name}"
	if params[:id]=="new"
		PersonPeriod.create params
	else
		pp = PersonPeriod.find(params[:id])
		pp.delete if (params[:commit]=="delete" && !pp.nil?)
		pp.update params if (params[:commit]=="save" && !pp.nil?)
	end
	partial :"frame/people_periods"
end

# renders a modal with a list of the people available for a task with a specific day schedule
get '/matrix/people_modal/ds/:ds/task/:task' do
	@ds  = (params[:ds].nil? ? nil : DaySchedule.find(params[:ds]))
	@task  = (params[:task].nil? ? nil : Task.find(params[:task]))
	@task_schedule = TaskSchedule.find_task_schedule(@task,@ds)
	@selected_people  = @ds.get_assigned_people @task
	@available_people = PersonPeriod.find_people_available(@ds, @task)
	@available_people.concat(@selected_people) unless @selected_people.nil?
	partial :"table/matrix/people_modal"
end


get '/matrix/ds/:ds/task/:task/person/:person' do
	@task  = (params[:task].nil? ? nil : Task.find(params[:task]))
	@ds  = (params[:ds].nil? ? nil : DaySchedule.find(params[:ds]))
	@person  = (params[:person].nil? ? nil : Person.find(params[:person]))
	TaskAssignment.create(day_schedule: @ds, task: @task, person: @person )
	partial :"table/matrix/day_schedule_cell"
end

# assigs a task assignment to a person and returs the correpsonding cell in the
# assignments table
get '/matrix/ds/:ds/task/:task/person/:person/remove' do
	@task  = (params[:task].nil? ? nil : Task.find(params[:task]))
	@ds  = (params[:ds].nil? ? nil : DaySchedule.find(params[:ds]))
	@person  = (params[:person].nil? ? nil : Person.find(params[:person]))
	TaskAssignment.find_by(day_schedule: @ds, task: @task, person: @person).destroy
	partial :"table/matrix/day_schedule_cell"
end
