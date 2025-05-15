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

class CrsRecord < ActiveRecord::Base

	self.table_name = "crs_records"

	belongs_to 	:person

	# default dates of ceremonies
	ADMISSIO_DATE = 	{day: 15, month: 10}
	LECTORADO_DATE = 	{day: 20, month: 10}
	ACOLITADO_DATE = 	{day: 20, month: 1 }

	# an enum with the different options for the seminary phases.
  enum :phase, {discipular: 0, configuracional: 1, sintesis: 2, propedeutica: 4}

#---------------------------------------------------------------------------------------
# CRUD METHODS
#---------------------------------------------------------------------------------------

	def self.create(params)
		super(CrsRecord.prepare_params params)
	end

	def update(params)
		super(CrsRecord.prepare_params params)
	end

	# make sure just parameters belonging to the model are passed to the constructor
  # @params [hash]: the parameters received from the form
	def self.prepare_params(params)
		params.select{|param| CrsRecord.attribute_names.include? param}
	end

	#---------------------------------------------------------------------------------------
	# ACCESSORS
	#---------------------------------------------------------------------------------------
	def self.get_ceremony_info(ceremony)

		people = Person.includes(:crs_record).laicos.in_rome.select{|person| (person.crs_record&.get_next(ceremony.to_sym)!=nil)}
		people = people.map {|p| [p.id, p.short_name, p.crs_record.get_next(ceremony.to_sym).strftime("%d-%m-%y")]}
		title = case ceremony
			when "fidelidad" 	then 	"Próximas Fidelidades"
			when "admissio" 	then	"Próximas Admissio"
			when "lectorado"	then	"Próximos Lectorados"
			when "acolitado"	then 	"Próximos Acolitados"
			end
			{
				"has_date"			=>	true,
				"ceremony" 	=>	ceremony,
				"title"			=>	title,
				"people"		=>	people,
			}
	end

	def self.get_phase_info(phase)
		#puts "got phase variable #{phase}"
		{
			"has_date"	=>	false,
			"people" 		=> 	Person.phase(phase).pluck(:id, :short_name),
			"title" 		=> 	"Etapa #{CrsRecord.phases.key(phase.to_i)}".capitalize
		}
	end

	def get_next(ceremony)
		case ceremony
		when :fidelidad 	then ((oblacion && !fidelidad) ? oblacion.next_year(5) : nil)
		when :admissio 		then (!admissio ? get_next_date(:admissio) : nil)
		when :lectorado 	then ((admissio && !lectorado) ? get_next_date(:lectorado) : nil)
		when :acolitado 	then ((lectorado && !acolitado) ? get_next_date(:acolitado) : nil)
		end
	end

	# gets the next occurrence of the date day-month.
	def get_next_date(ceremony)
		date = case ceremony
			when :admissio 	then Date.new(Date.today.year, ADMISSIO_DATE[:month], 	ADMISSIO_DATE[:day])
			when :lectorado then Date.new(Date.today.year, LECTORADO_DATE[:month], 	LECTORADO_DATE[:day])
			when :acolitado then Date.new(Date.today.year, ACOLITADO_DATE[:month], 	ACOLITADO_DATE[:day])
		end
		(Date.today < date) ? date : date.next_year(1)
	end


end #class end
