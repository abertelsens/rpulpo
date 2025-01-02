
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

  # make sure just parameters belonging to the model are passed to the constructor
  # @params [hash]: the parameters received from the form
  def self.prepare_params(params)
    params.select{|param| Study.attribute_names.include? param}
  end

end
