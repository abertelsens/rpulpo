# situation.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a situation.
#---------------------------------------------------------------------------------------
#
class Situation < ActiveRecord::Base

  #has_many :time_situations, dependent: :destroy

	# the default scoped defines the default sort order of the query results
	default_scope { order(points: :asc) }


	def self.create(params)
		super(Situation.prepare_params params)
	end

	def update(params)
		super(Situation.prepare_params params)
	end

	def self.prepare_params(params)
		{
			name: params[:name],
			points: params[:points]
		}
	end

end # class end
