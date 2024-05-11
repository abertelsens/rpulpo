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

get '/tmp/media/:path' do
	puts "serving static media file #{File.join(settings.public_folder, 'tmp/media/#{params[:path]}')}"
	send_file File.join(settings.public_folder, 'tmp/media/#{params[:path]}')
end
