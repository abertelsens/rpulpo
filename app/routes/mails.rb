
# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MAILS TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------

DEFAULT_MAIL_QUERY = {q: "", year:Date.today.year(), direction:"-1", entity:"-1", mail_status:"-1", assigned:"-1"}

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
	@unread = @current_user.get_mails(:unread)
	partial :"table/mail"
end

get '/mail/search' do
	@current_user = get_current_user
	@mails_query = session["mails_table_query"] = params
	@objects = Mail.search params
	@unread = @current_user.get_mails(:unread)
	partial :"table/mail"
end

get '/mail/:id/related_files' do
	@object = Mail.find(params[:id])
	partial :"form/mail/related_files"
end

get '/mail/:id/document_links' do
	@object = Mail.find(params[:id])
	@references = @object.refs
	@answers = @object.ans
	partial :"form/mail/document_links"
end

# updates the mail objects and sends a json response.ù
# This method is called by the mailform controller in order to check with the user input if the
# strings corresponding ot the protoco, references and answers is well formed.
# @returns a json object of the form {result: boolean, data: [protocol: string, status: boolean]}
get '/mail/:id/update' do
	mail = Mail.find(params[:id])
	res =
		if params.key?(:protocol) 			then mail.update_protocol params[:protocol]
		elsif params.key?(:sendfile) 		then mail.send_related_files_to_user get_current_user
		elsif params.key?(:references) 	then mail.update_association params[:references], :references
		elsif params.key?(:answers) 		then mail.update_association params[:answers], :answers
	end
	res.to_json
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
		assigned_users: [get_current_user]
		}
	Mail.create(p)
	redirect '/mails'
end


# prepares a text for the current mail entry
get '/mail/:id/prepare_answer' do
	@object = Mail.find(params[:id])
	puts "answer"
	puts "------------------------------------------"
	puts object.prepare_answer
	puts "------------------------------------------"

	# partial :"form/mail"
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
