
# crs.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-08-25
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# This file defines the data used for the information related to the crs+
#---------------------------------------------------------------------------------------

class Crs < ActiveRecord::Base

	# an enum with the different options for the seminary phases.
  enum phase:     {discipular: 0, configuracional:1, síntesis:2, propedeutica: 4}

	belongs_to 	:person

	def self.prepare_params(params)
		params[:phase] = nil if params[:phase].blank?
		params[:cfi] = nil if params[:cfi].blank?
		params.except("crs_id", "id", "commit")
	end

	def self.get_editable_attributes()
		[ {name: "phase", value: "options", description: "etapa (dicasterio)"} ]
	end

	def get_next_fidelidad
		(!oblacion.nil? && fidelidad.nil?) ? oblacion.next_year(5) : nil
	end

	def get_next_admissio
		admissio.nil? ? get_next_date(10,15) : nil
	end

	def get_next_lectorado
		if !(person.status=="laico" && person.ctr!="se_ha_ido" && !admissio.nil? && lectorado.nil?)
			nil
		else
			get_next_date(10,20)
		end
	end

	def get_next_acolitado
		if !(person.status=="laico" && person.ctr!="se_ha_ido" && !admissio.nil? && !lectorado.nil? && acolitado.nil?)
			nil
		else
			get_next_date(1,20)
		end
	end
end #class end

# gets the next occurrence of the date day-month.
def get_next_date(month,day)
	date = Date.new(Date.today.year,month,day)
	(Date.today < date) ? date : date.next_year(1)
end
