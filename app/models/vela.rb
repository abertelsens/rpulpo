###########################################################################################
# DESCRIPTION
# A class defining a Document object.
###########################################################################################

require_rel '../engines'

#A class containing the Users data
class Vela < ActiveRecord::Base

	
=begin	
		# if a document is destroyed then we delete the associated file
		before_destroy do |doc|
			if doc.engine!="prawn"
					full_path = doc.get_full_path
					FileUtils.rm full_path if File.file? full_path
				end
		end
=end
		
	def self.prepare_params(params)
		{
			date:	params[:date],
			start_time:	params[:start_time],
			end_time:	params[:end_time],
			order: params[:order]
		}	
	end

	def self.create_from_params(params)
		Vela.create (Vela.prepare_params params)
	end
		
	def update_from_params(params)
		update(Vela.prepare_params params)
	end


end