
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
		session["#{args.to_s}_table_query"]
	end

	def get_last_filter(args)
		session["#{args.to_s}_table_filter"]
	end

	# Retrieves the table settings. The table settings specify which colums should be displayed.
	# The settings are stored in a cookie.
	# If no settings are stored then new default table settings are created and stored.
	# @args a symbol specifing the table.
	def get_last_table_settings args
		session["#{args.to_s}_table_settings"].nil? ? TableSettings.get("#{args.to_s}_default".to_sym) : session["#{args.to_s}_table_settings"]
	end

	def get_last_query_variables(args)

		case args
			when :people
				@people_query 					= get_last_query :people
				@people_filter 					= get_last_filter :people
				@people_table_settings 	= get_last_table_settings :people

			when :permits
				@permits_query 					= get_last_query :permits
				@permits_filter 				= get_last_filter :permits
				@permits_table_settings = get_last_table_settings :permits

			when :rooms
				@rooms_query 						= get_last_query :rooms
				@rooms_filter 					= get_last_filter :rooms
				@rooms_table_settings		= get_last_table_settings :rooms
		end
	end

	def get_current_people_set
		get_last_query_variables :people
		@people_query.nil? ? Person.all : (Person.search @people_query, @people_table_settings)
	end
	
	# Get the current user id. If no user is logged in nil is returned.
	def get_current_user()
			(cookies[:current_user_id].nil? || cookies[:current_user_id]&.blank?) ? nil : User.find(cookies[:current_user_id])
	end

	def save?
		params[:commit]=="save"
	end

	def new_id?
		params[:id]=="new"
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

	def render_document(writer)
		# check the status of the writer
		if writer.status==DocumentWriter::WARNING
			puts Rainbow(writer.message).orange
		elsif	writer.status==DocumentWriter::FATAL
			puts Rainbow(writer.message).red
			return partial :"errors/writer_error"
		end
		send_file writer.render, :type => :pdf
	end
end #helpers end
