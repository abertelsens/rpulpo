########################################################################################
# ROUTES CONTROLLERS FOR THE USERS TABLES
########################################################################################

########################################################################################
# GET ROUTES
########################################################################################


# renders the people frame after setting the current peopleset
get '/mails/frame' do
    get_last_query :mails   
    @mails_query = session["mails_table_query"] = {q: "", year:Date.today.year(), direction:"-1", entity:"-1", mail_status:"-1", assigned:"-1"} if @mails_query.nil? 
    partial :"frame/mails"
end

# renders the table of people
# @objects the people that will be shown in the table
get '/mails/table' do
    @objects = Mail.search (get_last_query :mails)
    @unread = UnreadMail.where(user: get_current_user).pluck(:mail_id)
    @unread = [] if @unread.nil?
    partial :"table/mail"
end

get '/mail/:id/update_form' do
    puts "got update_form submission"
    puts params
    puts request.POST.inspect
    return {result: true}.to_json
end

get '/mail/search' do
    
    #condition = "topic ILIKE '%#{params[:q]}%'"
    #@objects = Mail.includes(:entity).where(condition).order(date: :desc)
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
        return (@object.update_protocol params[:protocol]).to_json
    elsif
        params.key?(:users)
        return (@object.send_related_files_to_users params[:users]).to_json
    elsif
        params.key?(:references)
        return (@object.check_protocols params[:references]).to_json
    elsif
        params.key?(:answers)
        return (@object.check_protocols params[:answers]).to_json
    else
        return {result:false, message:"unknown parameters to update"}.to_json
    end

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
    redirect '/mails/frame'
end

