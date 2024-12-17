
# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MAILS TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------
require 'pandoc-ruby'

DEFAULT_MAIL_QUERY = {q: "", year:Date.today.year(), direction:"", entity:"", mail_status:"", assigned:""}
PANDOC_REFERENCE = "app/engines-templates/word/custom-reference.docx"


get '/mails' do
	@current_user = get_current_user
	@mails_query = session["mails_table_query"]
	@mails_query = DEFAULT_MAIL_QUERY if @mails_query.nil?
	partial :"frame/mails"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/mails/table' do
	@current_user = get_current_user
	@mails_query = session["mails_table_query"]
	@mails_query = DEFAULT_MAIL_QUERY if @mails_query.nil?
	@objects = Mail.search @mails_query
	@unread = @current_user.unread_mails.pluck(:mail_id)
	partial :"table/mail"
end

get '/mail/search' do
	@current_user = get_current_user
	@mails_query = session["mails_table_query"] = params
	@objects = Mail.search params
	@unread = @current_user.unread_mails
	partial :"table/mail"
end

get '/mail/:id/related_files' do
	@object = Mail.find(params[:id])
	partial :"form/mail/related_files"
end

get '/mail/:id/document_links' do
	@object = Mail.find(params[:id])
	@related_files = @object.find_related_files
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
get '/mail/:id/answer' do
	mail = Mail.find(params[:id])
	answer_protocol = Mail.assign_protocol(mail.entity)
	answer = Mail.create(entity: mail.entity, topic: "Respondemos sobre #{mail.topic}", protocol: answer_protocol, direction: "salida", refs_string: mail.protocol, date: DateTime.now)
	Reference.create(mail: answer, reference: mail)
	Answer.create(mail: mail, answer: answer)
	mail.update(ans_string: mail.ans.pluck(:protocol).join(", "))
	@object = answer
	partial :"form/mail"
end

# Regular Expression Matching
get %r{/mail/draft-([\w]+)} do |id|
	headers 'content-type' => "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
	html_src = Mail.find(id).prepare_text(get_current_user)
	PandocRuby.html(html_src, :standalone, "--reference-doc \"#{PANDOC_REFERENCE}\" --preserve-tabs").to_docx
end

# renders a single document view
get '/mail/mark_as_read' do
	get_current_user.unread_mails.destroy_all
	redirect '/mails/table'
end

# renders a single document view
get '/mail/delete_year' do
	puts "POSTING DELETE YEAR"
	Mail.with_year(params[:year].to_i).delete_all
	{result: true}.to_json
end

# renders a single document view
get '/mail/:id' do
	@object = (params[:id]=="new" ? Mail.create_from_params() : Mail.find(params[:id]))
	puts "created object #{@object.inspect}"
	unread = UnreadMail.find_by(mail: @object, user: get_current_user)
	unread.destroy unless (unread.nil? || params[:id]=="new")
	@related_files = @object.find_related_files
	partial :"form/mail"
end



########################################################################################
# POST ROUTES
########################################################################################

post '/mail/:id' do
	puts Rainbow("posting mail").orange
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


# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MAILFILES TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------

get '/mail_file/:id' do
	@object = MailFile.find(params[:id])
	if (@object.is_word_file? || @object.is_pdf_file?)
		partial :"form/mail/mail_file"

	# if it is not a pdf or a word file we try to open it via the file system.
	else
		begin
			puts "trying to get file #{@object.get_path} from filesystem"
			#system %{cmd /c "start \"#{@object.get_path}\""}
			system('start', '', @object.get_path)
		rescue
			"<turbo-frame id=\"mail-file-frame\">
			<row class=\"u-text-center\">
			<h3 style=\"margin-top: 3rem\"><i class=\"fa-solid fa-triangle-exclamation\"></i></h1>
			<h5 style=\"margin-top: 0rem\">Sorry but could not open file. <br>Maybe I don't have access.</h5>
			</row>
			</turbo-frame>"
		end
	end
end

# serves embedded images in word documents which are stored by pandoc in the public/tmp/media directory
get '/public/tmp/media/:path' do
	send_file File.join(settings.public_folder, "tmp/media/#{params[:path]}")
end
