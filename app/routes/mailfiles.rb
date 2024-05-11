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

# serves embedded images in word documents which are stored by pandoc in the public/tmp/media directory
get '/public/tmp/media/:path' do
	send_file File.join(settings.public_folder, "tmp/media/#{params[:path]}")
end

# serves files in the sect directory
get '/mnt/sect/:path' do
	send_file File("mnt/sect/#{params[:path]}")
end
