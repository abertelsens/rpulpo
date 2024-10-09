
# personal.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the data used for the personal information of someone
#---------------------------------------------------------------------------------------

class Personal < ActiveRecord::Base

	belongs_to 	:person

  def self.prepare_params(params)
    params.except("personal_id", "id", "commit")
  end

end # class end
