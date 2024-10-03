###########################################################################################
# A class defining a correo entry.
###########################################################################################
require 'rubyXL'

class Situation < ActiveRecord::Base

  has_many :time_situations, dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(points: :asc) }

  def self.create_update(params)
		puts "creating updating situation wiht params #{params}"
		if params[:id]=="new"
			@situation = Situation.create(prepare_params params)
		else
			@situation = Situation.find(params[:id])
			@situation.update(prepare_params params)
		end
  end


	def self.prepare_params(params)
	{
		name: params[:name],
		points: params[:points]
	}
	end

end
