# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MAILFILES TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------

get '/mailfile/:id' do
	@object = MailFile.find(params[:id])
	@type = params[:type]
	partial :"form/mail/mailfile"
end

get '/public/tmp/media/:path' do
	send_file File.join(settings.public_folder, 'tmp/media/#{params[:path]}')
end
