
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

  def self.create(params)
    super(Study.prepare_params params)
  end

  def update(params)
    super(Study.prepare_params params)
  end

  def self.prepare_params(params)
    params.except("study_id", "id", "commit", "module")
  end

end
