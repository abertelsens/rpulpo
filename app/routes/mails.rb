
# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MAILS TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------

DEFAULT_MAIL_QUERY = {q: "", year:Date.today.year(), direction:"-1", entity:"-1", mail_status:"-1", assigned:"-1"}

# renders the people frame after setting the current peopleset
get '/mails' do
	@current_user = get_current_user
	get_last_query :mails
	@mails_query = session["mails_table_query"] = DEFAULT_MAIL_QUERY if @mails_query.nil?
	partial :"frame/mails"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/mails/table' do
	@current_user = get_current_user
	@objects = Mail.search (get_last_query :mails)
	@unread = @current_user.unread_mails.pluck(:mail_id)
	@unread = [] if @unread.nil?
	partial :"table/mail"
end

get '/mail/search' do
	@mails_query = session["mails_table_query"] = params
	@objects = Mail.search params
	@unread = UnreadMail.where(user: get_current_user)
	@unread = [] if @unread.nil?
	partial :"table/mail"
end

get '/mail/:id/related_files' do
	@object = Mail.find(params[:id])
	partial :"form/mail/related_files"
end

get '/mail/:id/document_links' do
	@object = Mail.find(params[:id])
	partial :"form/mail/document_links"
end


# updates the mail objects and sends a json response
get '/mail/:id/update' do
	@object = Mail.find(params[:id])
	if params.key?(:protocol)
		(@object.update_protocol params[:protocol]).to_json
	elsif
		params.key?(:users)
		(@object.send_related_files_to_users params[:users]).to_json
	elsif
		params.key?(:references)
		(@object.update_references params[:references]).to_json
	elsif
		params.key?(:answers)
		(@object.update_answers params[:answers]).to_json
	end
end

get '/mail/assign_protocol' do
	entity = Entity.find(params[:entity])
	protocol = Mail.assign_protocol(entity)
	p = {
		date:					Date.today,
		topic:				params[:topic],
		protocol:			protocol,
		mail_status:	"en_curso",
		entity:				entity,
		direction:		"salida",
		assignedusers: [get_current_user]
		}
	Mail.create(p)
	redirect '/mails'
end


# renders a single document view
get '/mail/:id' do
	@object = (params[:id]=="new" ? Mail.create_from_params() : Mail.find(params[:id]))
	unread = UnreadMail.find_by(mail: @object, user: get_current_user)
	unread.destroy unless (unread.nil? || params[:id]=="new")
	partial :"form/mail"
end



########################################################################################
# POST ROUTES
########################################################################################

post '/mail/:id' do
	@mail = (params[:id]=="new" ? nil : Mail.find(params[:id]))
	case params[:commit]
		when "save"
			@mail  = @mail.nil? ? (Mail.create_from_params params) : (@mail.update_from_params params)
			check_update_result @mail
		when "delete"
			@mail.destroy
	end
	redirect '/mails'
end
