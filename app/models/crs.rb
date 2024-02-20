class Crs < ActiveRecord::Base

    enum phase:     {discipular: 0, configuracional:1, síntesis:2, propedeutica: 4}

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
            notes:        	params[:notes],
            phase:        	params[:phase]
        }
    end

    def can_be_deleted?
       true
    end

    def self.get_editable_attributes()
        [
            {name: "phase",          value: "options",   description: "etapa (dicasterio)"},
        ]
        end

        def get_next_fidelidad
			(fidelidad.nil? || fidelidad < Date.today) ? false : oblacion.next_year(5)
		end

		def get_next_admissio
			admissio.nil?
		end

		def get_next_lectorado
			(person.status=="laico" && person.ctr!="se_ha_ido" && !admissio.nil? && lectorado.nil?)
		end
end #class end
