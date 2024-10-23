
# sinatra_helpers.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file define a series of auxiliary methods used in the sinatra routes.
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# SINATRA HELPER METHODS
#---------------------------------------------------------------------------------------

helpers do

	# checks the update result of an object. The method is called after an update operation
	# on the db
	# @result: the result object after the update operation
	def check_update_result(result)
			puts Rainbow("error while updating\n #{result.error_messages}").yellow unless result
	end

	# retrieves the last query used by the user in the session. The queries are stored in cookies.
	# the method is used to remember what query the user was using so that when he goes back
	# -after updating a record, for example- he will not have to enter it again.
	# @args a symbol specifing the table
	def get_last_query(args)
		case args
				when :people    then @people_query = session["people_table_query"]
				when :rooms     then @rooms_query = session["rooms_table_query"]
				when :mails     then return @mails_query = session["mails_table_query"]
		end
		get_table_settings args
	end

	def get_last_filter(args)
		case args
				when :people    then @people_filter = session["people_table_filter"]
		end
	end

	# Retrieves the table settings. The table settings specify which colums should be displayed.
	# The settings are stored in a cookie.
	# If no settings are stored then new default table settings are created and stored.
	# @args a symbol specifing the table.
	def get_table_settings args
		case args
			when :people
					@people_table_settings = session["people_table_settings"].nil? ? TableSettings.get(:people_default) : session["people_table_settings"]
			when :rooms
					@rooms_table_settings = session["rooms_table_settings"].nil? ? TableSettings.get(:rooms_default) : session["rooms_table_settings"]
		end
	end

	# Get the current user id. If no user is logged in nil is returned.
	def get_current_user()
			(cookies[:current_user_id].nil? || cookies[:current_user_id]&.blank?) ? nil : User.find(cookies[:current_user_id])
	end

	def save?
		params[:commit]=="save"
	end

	# Prints a log of the http request. The info varies according to the SINATRA_LOG_LEVEL variable.
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

end #helpers end
