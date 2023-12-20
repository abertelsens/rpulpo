########################################################################################
# ROUTES CONTROLLERS FOR THE PEOPLE TABLES
########################################################################################

# renders the people frame
get '/people/frame' do
  partial :"frame/people"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/people/table' do
  @objects = Person.includes(:room).all.order(full_name: :asc)
  partial :"table/people"
end

# renders the table of after perfroming a search.
get '/people/search' do
  @objects = Person.includes(:room).search(params[:q],params[:sort_order])
  partial :"table/people"
end

# renders a single person view
get '/person/:id' do
  @person = Person.find(params[:id])
  partial :"view/person"
end

# renders a form of a single person view
get '/person/:id/:module' do
	@person = (params[:id]=="new" ? nil : Person.find(params[:id]))
	case params[:module]
		when "personal" then @personal = Personal.find_by(person_id: @person.id)
		when "study" 		then @study = Study.find_by(person_id: @person.id)
		when "crs" 			then @crs = Crs.find_by(person_id: @person.id)
	end
	partial :"form/person/#{params[:module]}"
end

########################################################################################
# POST ROUTES
########################################################################################
post '/person/:id/general' do
	@person = (params[:id]=="new" ? nil : Person.find(params[:id]))
	case params[:commit]
		when "save"     
			if @person.nil? 
				@person = Person.create_from_params params
			else
				check_update_result (@person.update_from_params params)
			end
		# if a person was deleted we go back to the screen fo the people table
		when "delete" 
				@person.destroy
				redirect '/people/table'
	end
	partial :"view/person"
end

# post controller of the personal data of a person
post '/person/:id/personal' do
    @person = Person.find(params[:id])
    @personal = params[:personal_id]=="new" ? nil : Personal.find(params[:personal_id])
    if params[:commit]=="save"
			if @personal.nil?
				@personal = Personal.create Personal.prepare_params params
			else
				check_update_result (@personal.update Personal.prepare_params params)
			end    
    end    
    partial :"view/person"
end

# post controller of the study data of a person
post '/person/:id/study' do
	@person = Person.find(params[:id])
	@study = params[:studies_id]=="new" ? nil : Study.find(params[:studies_id])
	if params[:commit]=="save"
		if @study.nil?
			@study = Study.create Study.prepare_params params
		else
			check_update_result (@study.update Study.prepare_params params)
		end    
	end    
	partial :"view/person"
end

# post controller of the crs data of a person
post '/person/:id/crs' do
	@person = Person.find(params[:id])
	@crs = params[:crs_id]=="new" ? nil : Crs.find(params[:crs_id])
	if params[:commit]=="save"
		if @crs.nil?
			@crs = Crs.create Crs.prepare_params params
		else
			check_update_result (@crs.update Crs.prepare_params params)
		end    
	end    
	partial :"view/person"
end


# uploads an image
post '/people/:id/image' do
    FileUtils.mv(params[:file][:tempfile], "app/public/photos/#{params[:id]}.jpg")
end