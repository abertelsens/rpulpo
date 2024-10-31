# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE MAILFILES TABLES
# -----------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------

get '/mail_file/:id' do
	@object = MailFile.find(params[:id])
	@type = params[:type]
	partial :"form/mail/mail_file"
end

# serves embedded images in word documents which are stored by pandoc in the public/tmp/media directory
get '/public/tmp/media/:path' do
	send_file File.join(settings.public_folder, "tmp/media/#{params[:path]}")
end
