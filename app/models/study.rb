class Study < ActiveRecord::Base

	belongs_to 	:person

	def self.prepare_params(params)
    {
			person_id: 				params[:person_id],
			civil_studies: 			params[:civil_studies],
			studies_name: 			params[:studies_name],
			degree: 				params[:degree],
			profesional_experience: params[:profesional_experience],
			year_of_studies: 		params[:year_of_studies],
			faculty: 				params[:faculty],
			status: 				params[:study_status],
			licence: 				params[:licence],
			doctorate: 				params[:doctorate],
			thesis: 				params[:thesis],
		}
  end

	def can_be_deleted?
		true
	end
end
