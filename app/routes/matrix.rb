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

get '/schedule/table' do
	@objects = Schedule.get_all
	@active = params[:active_table]=="true"
	partial :"table/matrix/schedule"
end

get '/schedule/:id' do
	@object = (params[:id]=="new" ? nil : (Schedule.find params[:id]))
	partial :"form/matrix/schedule"
end

post '/schedule/:id' do
	case params[:commit]
	when "new"		then	Schedule.create params
	when "save" 	then 	Schedule.find(params[:id]).update params
	when "delete" then 	Schedule.find(params[:id]).destroy
	end
	redirect '/matrix'
end

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/schedule/:id/validate' do
	content_type :json
	(new_id? ? (Schedule.validate params) : (Schedule.find(params[:id]).validate params)).to_json
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

# assigns all tasks for the period
get '/matrix/period/:id/assign' do
	Matrix.assign_all_tasks Period.find(params[:id])
	redirect "/matrix/period/#{params[:id]}/task_assignment/table?week=1"
end

# Shows one week of the the assignments table for the period.
get '/matrix/period/:id/task_assignment/table' do
	@week = (params[:week]=nil? ? 1 : params[:week].to_i)
	@period = Period.find(params[:id])
	@schedules = Schedule.all
	@day_schedules = @period.get_week @week
	@tasks = Task.all
	partial :"table/matrix/task_assignment"
end

# -----------------------------------------------------------------------------------------
# PERSON PERIODS
# -----------------------------------------------------------------------------------------

get '/matrix/people_periods/table' do
	@objects = PersonPeriod.includes(:person).all.order("people.family_name")
	partial :"table/matrix/people_periods"
end

get '/matrix/people_periods/table/search' do
	@objects = PersonPeriod.joins(:person).where("people.short_name ILIKE '%#{params[:q]}%'").order("people.family_name")
	partial :"table/matrix/people_periods"
end

get '/matrix/people_periods' do
	partial :"frame/people_periods"
end

get '/matrix/person_period/:id' do
	@object = (params[:id]=="new" ? nil : PersonPeriod.find(params[:id]))
	@availability = @object.nil? ? nil : @object.days_available.order(day: :asc)
	partial :"form/matrix/person_period"
end

post '/matrix/person_period/:id' do
	person_period = PersonPeriod.find(params[:id]) unless params[:id]=="new"
	case params[:commit]
		when "save" then (person_period==nil ? (PersonPeriod.create params ): (person_period.update params))
		when "delete" then person_period.destroy
	end
	partial :"frame/people_periods"
end

# -----------------------------------------------------------------------------------------
# DAY SCHEDULES
# -----------------------------------------------------------------------------------------

get '/matrix/day_schedule/:id' do
	@object = (params[:id]=="new" ? nil : DaySchedule.includes(:schedule).find(params[:id]))
	partial :"form/matrix/day_schedule"
end

# updates the schedule type of a specific day schedule. It is called via a script so therefore
# there is no need to return a view.
post '/matrix/day_schedule/:ds/schedule/:schedule' do
	ds = DaySchedule.find params[:ds]
	schedule = Schedule.find params[:schedule]
	ds.update(schedule: schedule)
	{result: true}.to_json

end

# renders a modal with a list of the people available for a task with a specific day schedule
get '/matrix/people_modal/ds/:ds/task/:task' do

	@ds  = DaySchedule.find params[:ds]
	@period = @ds.period
	@task  = Task.find params[:task]
	@available_people = Matrix.find_hash_people_available(@period,@ds,@task)
	@people_needed = @ds.get_number @task
	@selected_people  = @ds.get_assigned_people @task
	@selected_people_ids  = @selected_people.pluck(:id)
	partial :"table/matrix/people_modal"
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
	partial :"table/matrix/day_schedule_cell"
end
