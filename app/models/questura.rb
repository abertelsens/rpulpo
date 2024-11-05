
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
    params = (Permit.prepare_params params).except("id")
    super(params)
  end

  def update(params)
    super(Permit.prepare_params params)
  end

  def self.prepare_params(params)
    params.select{|param| Permit.attribute_names.include? param}
  end

  def self.search(search_string, table_settings=nil)
		PulpoQuery.new(search_string, table_settings).execute
  end

  def days_to_expire()
    (permit_expiration- Date.today).to_i
  end

end
