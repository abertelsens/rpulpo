########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################

# renders the people frame
get '/matrix' do
	#@current_user = get_current_user
	#get_last_query :rooms
  partial :"frame/matrix"
end

get '/matrix/day_type/table' do
	@objects = DayType.all.order(name: :asc)
	partial :"table/matrix/day_type"
end

get '/matrix/day_type/:id' do
	@object = (params[:id]=="new" ? nil : DayType.find(params[:id]))
	partial :"form/matrix/day_type"
end

post '/matrix/day_type/:id' do
	@dt = (params[:id]=="new" ? nil : DayType.find(params[:id]))
	case params[:commit]
	when "save"
		if @dt.nil?
			@dt = DayType.create(name: params[:name],description: params[:description])
		else
			@dt.update(name: params[:name],description: params[:description])
		end
	# if a person was deleted we go back to the screen fo the people table
	when "delete"
			@dt.destroy
			redirect :"/matrix"
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
	# if a person was deleted we go back to the screen fo the people table
	when "delete"
			@task.destroy
			redirect :"/matrix"
	end
	redirect :"/matrix"
end


get '/matrix/task_type/table' do
	@objects = TaskType.all.order(task_id: :asc)
	partial :"table/matrix/task_type"
end

get '/matrix/task_type/:id' do
	@object = (params[:id]=="new" ? nil : TaskType.find(params[:id]))
	partial :"form/matrix/task_type"
end

post '/matrix/task_type/:id' do
	@tt = (params[:id]=="new" ? nil : TaskType.find(params[:id]))
	case params[:commit]
	when "save"
		if @tt.nil?
			@tt = TaskType.create(TaskType.prepare_params params)
		else
			@tt.update(TaskType.prepare_params params)
		end
	# if a person was deleted we go back to the screen fo the people table
	when "delete"
			@task.destroy
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
	@p = (params[:id]=="new" ? nil : Period.find(params[:id]))
	case params[:commit]
	when "save"
		if @p.nil?
			@p = Period.create(Period.prepare_params params)
			@p.create_days
		else
			@p.update(Period.prepare_params params)
			#@p.update_days I need to implement this
		end
	# if a person was deleted we go back to the screen fo the people table
	when "delete"
			@p.destroy
			redirect :"/matrix"
	end
	redirect :"/matrix"
end

get '/matrix/period/:id/task_assignment/table' do
	@object = (params[:id]=="new" ? nil : Period.find(params[:id]))
	@assignments = @object.get_task_assignments
	partial :"table/matrix/task_assignment"
end

get '/matrix/date_type/:id' do
	@object = (params[:id]=="new" ? nil : DateType.includes(:day_type).find(params[:id]))
	partial :"form/matrix/date_type"
end

post '/matrix/date_type/:id' do
	@object = DateType.find(params[:id])
	puts Rainbow("got params #{params}").purple
	params["task"].keys.each do |key|
		task = Task.find(key)
		date_type = @object
		person = Person.find(params["task"][key])
		TaskAssignment.assign(task, date_type, person)
	end
	redirect "/matrix/period/#{@object.period.id}"
end
