
# crs.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the data related to the studies of a person
#---------------------------------------------------------------------------------------

class Study < ActiveRecord::Base

	belongs_to 	:person

	def self.prepare_params(params)
    params.except("studies_id", "id", "commit")
  end

end
