class Crs < ActiveRecord::Base

  enum phase:     {discipular: 0, configuracional:1, síntesis:2, propedeutica: 4}

	belongs_to 	:person

	def self.prepare_params(params)
		{
		person_id: 		params[:person_id],
		classnumber:  params[:classnumber],
		pa:    		 		params[:pa],
		admision:    	params[:admision],
		oblacion:     params[:oblacion],
		fidelidad:    params[:fidelidad],
		letter:    		params[:letter],
		admissio:     params[:admissio],
		presbiterado: params[:presbiterado],
		diaconado:    params[:diaconado],
		acolitado:    params[:acolitado],
		lectorado:    params[:lectorado],
		cipna:        params[:cipna],
		notes:        params[:notes],
		phase:        params[:phase].blank? ? nil : params[:phase],
		cfi:        	params[:cfi].blank? ? nil : params[:cfi]
		}
	end

	def can_be_deleted?
		true
	end

	def self.get_editable_attributes()
		[ {name: "phase", value: "options", description: "etapa (dicasterio)"} ]
	end

	def get_next_fidelidad
		#fidelidad < Date.today
		(fidelidad.nil? || oblacion.nil?) ? nil : oblacion.next_year(5)
	end

	def get_next_admissio
		admissio.nil? ? get_next_date(10,15) : nil
	end

	def get_next_lectorado
		if !(person.status=="laico" && person.ctr!="se_ha_ido" && !admissio.nil? && lectorado.nil?)
			return nil
		else
			get_next_date(10,20)
		end
	end

	def get_next_acolitado
		if !(person.status=="laico" && person.ctr!="se_ha_ido" && !admissio.nil? && !lectorado.nil? && acolitado.nil?)
			return nil
		else
			get_next_date(1,20)
		end
	end
end #class end

def get_next_date(month,day)
	if Date.today < Date.new(Date.today.year,month,day)
		Date.new(Date.today.year,month,day)
	else
		Date.new(Date.today.year+1,month,day)
	end
end
