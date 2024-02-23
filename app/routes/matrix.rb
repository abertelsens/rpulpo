########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################

# renders the main matrix frame
get '/matrix' do
  partial :"frame/matrix"
end

get '/matrix/schedule/table' do
	@objects = Schedule.all.order(name: :asc)
	partial :"table/matrix/schedule"
end

get '/matrix/schedule/:id' do
	@object = (params[:id]=="new" ? nil : Schedule.find(params[:id]))
	partial :"form/matrix/schedule"
end

post '/matrix/schedule/:id' do
	@schedule = (params[:id]=="new" ? nil : Schedule.find(params[:id]))
	case params[:commit]
	when "save"
		if @schedule.nil?
			@schedule = Schedule.create(name: params[:name],description: params[:description])
		else
			@schedule.update(name: params[:name],description: params[:description])
		end
	when "delete"
			@schedule.destroy
	end
	redirect :"/matrix"
end

get '/matrix/task/table' do
	@objects = Task.all.order(name: :asc)
	partial :"table/matrix/task"
end

get '/matrix/task/:id' do
	@object = (params[:id]=="new" ? nil : Task.find(params[:id]))
	partial :"form/matrix/task"
end

post '/matrix/task/:id' do
	@task = (params[:id]=="new" ? nil : Task.find(params[:id]))
	case params[:commit]
	when "save"
		if @task.nil?
			@task = Task.create(name: params[:name])
		else
			@task.update(name: params[:name])
		end
		@task.update_task_schedules(params["number"],params["s_time"],params["e_time"],params["notes"])
	when "delete"
		@task.destroy
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
	# if a person was deleted we go back to the screen fo the people table
	when "delete"
			@task_schedule.destroy
			redirect :"/matrix"
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
			#@p.update_days I need to implement this
		end
	# if a person was deleted we go back to the screen fo the people table
	when "delete"
			@period.destroy
			redirect :"/matrix"
	end
	redirect :"/matrix"
end

get '/matrix/period/:id/task_assignment/table' do
	@object = (params[:id]=="new" ? nil : Period.find(params[:id]))
	@assignments = @object.get_task_assignments
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
		#person = params["task"][key].blank? ? nil : Person.find(params["task"][key])
		TaskAssignment.assign(task, day_schedule, people)
	end
	redirect "/matrix/period/#{@object.period.id}"
end

get '/matrix/day_schedule/:id/task_assignments' do
	@object = (params[:id]=="new" ? nil : DaySchedule.includes(:schedule).find(params[:id]))
	partial :"form/matrix/task_assignments"
end
