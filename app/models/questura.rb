
# crs.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the data related to residence permits
#---------------------------------------------------------------------------------------

class Permit < ActiveRecord::Base

	belongs_to 	:person

  def self.create(params)
    super(Permit.prepare_params params)
  end

  def update(params)
    super(Permit.prepare_params params)
  end

  def self.prepare_params(params)
    params.select{|param| Permit.attribute_names.include? param}
  end

end
