class Crs < ActiveRecord::Base

	belongs_to 	:person
	
	def self.prepare_params(params)
        {
            person_id: 		params[:person_id],
            classnumber:   	params[:classnumber],
            pa:    		 	params[:pa],
            admision:    	params[:admision],
            oblacion:     	params[:oblacion],
            fidelidad:     	params[:fidelidad],
            letter:    		params[:letter],
            admissio:       params[:admissio],
            presbiterado:   params[:presbiterado],
            diaconado:      params[:diaconado],
            acolitado:      params[:acolitado],
            lectorado:    	params[:lectorado],
            cipna:        	params[:cipna],
            notes:        	params[:notes]    
        }
    end

    def can_be_deleted?
       true
    end

    def get_next_fidelidad
			if (fidelidad.nil? || fidelidad < Date.today)
				false
			else
				oblacion.next_year(5)
			end
		end

		def get_next_admissio
			admissio.nil?
		end

		def get_next_lectorado
			(person.status=="laico" && person.ctr!="se_ha_ido" && !admissio.nil? && lectorado.nil?)
		end
end #class end