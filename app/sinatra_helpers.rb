#---------------------------------------------------------------------------------------
# SINATRA HELPER METHODS
#---------------------------------------------------------------------------------------

helpers do

	def check_update_result(result)
			puts Rainbow("error while updating\n #{result.error_messages}").yellow unless result
	end

	def get_last_query(args)
		case args
				when :people    then @people_query = session["people_table_query"]
				when :rooms     then @rooms_query = session["rooms_table_query"]
				when :mails     then return @mails_query = session["mails_table_query"]
		end
		get_table_settings args
	end

	def get_table_settings args
		case args
		when :people
				@people_table_settings = session["people_table_settings"].nil? ? TableSettings.new(table: :people_default) : session["people_table_settings"]
		when :rooms
				@rooms_table_settings = session["rooms_table_settings"].nil? ? TableSettings.new(table: :rooms_default) : session["rooms_table_settings"]
		end
	end

	def check_permission(resource)
		@user = User.get_user(session[:current_user_id])
		partial :"/login" if @user.nil?

		@auth = @user.check_permission(resource)
		return (partial :"unauthorized") if @auth==User::NONE #if the authorization was not found we redirect to unauthorized page
		return @auth
	end

	def get_current_user()
			(cookies[:current_user_id].nil? || cookies[:current_user_id]&.blank?) ? nil : User.find(cookies[:current_user_id])
	end

	#checks if the edit/new/delete action produced any errors and redirects to the
	#corresponding error page
	def error_screen(object)
		partial "screen/error", locals: {error: object.error}
	end

	def print_controller_log()
		case SINATRA_LOG_LEVEL
			when 1
				puts Rainbow("--------------------------------------------").red
				puts Rainbow("#{request.fullpath}").red
				puts Rainbow("route: #{request.path_info}").red
				puts Rainbow("--------------------------------------------").red
			when 2
				puts Rainbow("--------------------------------------------").red
				puts Rainbow("#{request.fullpath}").red
				puts Rainbow("route: #{request.path_info}").red
				puts Rainbow("params: #{params}").yellow
				puts Rainbow("--------------------------------------------").red
		end
	end

end
