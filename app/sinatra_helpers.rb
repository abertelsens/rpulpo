
# sinatra_helpers.rb
#---------------------------------------------------------------------------------------
# FILE INFO
# autor: alejandrobertelsen@gmail.com
# last major update: 2025-03-26
# ---------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------
# DESCRIPTION
# This file define a series of auxiliary methods used in the sinatra routes.
# ---------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------
# SINATRA HELPER METHODS
# ---------------------------------------------------------------------------------------

def warning(msg)
	puts Rainbow(msg).orange
end

def log(msg)
	puts Rainbow(msg).green
end

helpers do

	# checks the update result of an object. The method is called after an update operation
	# on the db
	# @result: the result object after the update operation
	def check_update_result(result)
		warning "error while updating\n #{result.error_messages}" unless result
	end

	# retrieves the last query used by the user in the session. The queries are stored in cookies.
	# the method is used to remember what query the user was using so that when he goes back
	# -after updating a record, for example- he will not have to enter it again.
	# @args a symbol specifing the table
	def get_last_query(args)
		session["#{args.to_s}_table_query"].presence
	end

	def get_last_filter(args)
		session["#{args}_table_filter"].presence
	end

	# Retrieves the table settings. The table settings specify which colums should be displayed.
	# The settings are stored in a cookie.
	# If no settings are stored then new default table settings are created and stored.
	# @args a symbol specifing the table.
	def get_last_table_settings(args)
		session["#{args}_table_settings"] || TableSettings.get("#{args}_default".to_sym)
	end

	def get_last_query_variables(args)
		valid_types = %i[people permits rooms]

		unless valid_types.include?(args)
			puts Rainbow("Invalid argument: #{args}. Expected one of #{valid_types}").orange
			return
		end

		instance_variable_set("@#{args}_query", get_last_query(args))
		instance_variable_set("@#{args}_filter", get_last_filter(args))
		instance_variable_set("@#{args}_table_settings", get_last_table_settings(args))
	end


	def get_current_people_set
		get_last_query_variables :people
		Person.search @people_query, @people_table_settings, @people_filter
	end

	# Get the current user id. If no user is logged in nil is returned.
	def get_current_user
		return nil if cookies[:current_user_id].blank?
		User.find_by(id: cookies[:current_user_id].to_i)
	end

	def save?
		params[:commit]=="save"
	end

	def new_id?
		params[:id]=="new"
	end

	# Prints a log of the http request. The info varies according to the SINATRA_LOG_LEVEL variable.
	def print_controller_log
		log_level = (SINATRA_LOG_LEVEL || 1).to_i  # Default to level 1
		divider = Rainbow("-" * 40).red

		log divider
		log "Request: #{request.fullpath}"
		log "Route: #{request.path_info}"
		log "Params: #{params}" unless params.empty? if log_level >= 2
		log divider
	end



end #helpers end
