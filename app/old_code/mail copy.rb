###########################################################################################
# A class defining a correo entry.
###########################################################################################
require 'rubyXL'

class Mail < ActiveRecord::Base

	BASE_DIR= "app/public"
	TMP_MAIL_CONTAINER = "app/public/tmp/mail"
	BALDAS_BAS_DIR = "L:/usuarios/sect/CORREO-CG/BALDAS"
	
	enum direction:    		{ entrada: 0, salida: 1} 
	enum mail_status:    	{ pendiente: 0, en_curso: 1, terminado: 2 } 

	belongs_to 	:entity
	#has_many 	:unreadmails, dependent: :destroy
	has_many 	:assigned_mails, dependent: :destroy
	has_many 	:assignedusers, :through => :assigned_mails, :source => :user, dependent: :destroy
	has_many 	:references, dependent: :destroy	
	has_many 	:refs,	:through => :references, 	:source => :reference
	has_many 	:answers, dependent: :destroy	
	has_many 	:ans,	:through => :answers, :source => :answer
	has_many 	:mail_files, dependent: :destroy
	
##########################################################################################
# STATIC METHODS
##########################################################################################
	
	# prepares params after receiving them from the form. 
	def self.prepare_params(params=nil)
		if params.nil? # no params provided. We create default params 
			{
			entity: 		Entity.find_by(sigla: "crs+"),
			date:				Date.today,
			topic:			"",
			protocol:		"crs+ XX/XX",
			direction:	0,	
			mail_status:0	
			}
		else
			{
			date:					Date.parse(params[:date]),
			topic:				params[:topic],
			protocol:			params[:protocol],
			mail_status:	params[:mail_status]	
			}
		end
	end

		# creates a user and updated the module permissions.
	def self.create_from_params(params=nil)
		Mail.create(prepare_params params)
	end

	def update_from_params(params)
		set_assigned_users(params[:assigned])
		set_references(params[:references])
		set_answers(params[:answers])
		update(Mail.prepare_params params)
	end
	
	# users arry contains an array of users ids
	def set_answers(answers_string)
		answers = answers_string.split(",").map{|prot| Mail.find_by(protocol: prot.strip)}
		answers==[] ? self.answers.destroy_all : self.update(ans: answers)
	end

	# users arry contains an array of users ids
	def set_references(references_string)
		references = references_string.split(",").map{|prot| Mail.find_by(protocol: prot.strip)}
		references==[] ? self.references.destroy_all : self.update(refs: references)
	end

	# users arry contains an array of users ids
	def check_protocols(protocols_string)
		return {result: true, data: nil} if protocols_string.strip.empty?
		protocols = protocols_string.split(",").map{|prot| prot.strip}
		r = protocols.map{|prot| {protocol: prot, status: !(Mail.find_by(protocol: prot).nil? )} }
		res = r.map{|elem| elem[:status]}.inject(:&)
		{result: res, data: r}
	end

	
	# users array contains an array of users ids
	def set_assigned_users(users_array)
		users_array.nil? ? AssignedMail.where(mail:self).destroy_all : self.update(assignedusers: User.find(users_array))
	end

	def send_related_files_to_users(users)
		set_assigned_users users.split(",")
		assignedusers.each {|u| (send_related_files_to_user u)} unless (users.nil? || users.blank?)
	end

	def send_related_files_to_user(user)
		balda = "#{BALDAS_BAS_DIR}/#{user.uname}"
		related_files = find_related_files
		if (related_files.size==1)
			f = related_files[0]
			res = FileUtils.cp("#{TMP_MAIL_CONTAINER}/#{f[:name]}","#{balda}/#{user.uname}-#{f[:name]}")
		else
			new_dir = "#{balda}/#{user.uname}-#{protocol.gsub("/","_")}"
			FileUtils.mkdir new_dir unless Dir.exist? new_dir
			related_files.each {|f| FileUtils.cp("#{BASE_DIR}/#{f[:href]}","#{new_dir}/#{f[:name]}") } 				
		end		 
	end
	
	# tries to suggest a direction and the entity fields from a protocol
	def update_protocol(protocol_string)
		data = {"result" => true, "entity" => nil, "direction"=> nil, "message"=>""}
		error_result = {"result" => false, "message"=> "El protocolo <b>#{protocol_string}</b> está mal formado"}
		num = protocol_string.match(/(?<num>[0-9]+)\/(?<year>[0-9]{2})/)
		entities = protocol_string.match(/(?<e1>[a-zA-Z]+\+*)\s*-*\s*(?<e2>[a-zA-Z]*\+*)/)
		
		return error_result if num.nil? 
			
		if entities.nil? # nota del cg. No tiene ningun tipo de entidad.
			data["entity"]="cg"
			data["direction"]="entrada"
		elsif entities[:e2].blank? && entities[:e1]=="crs+" #nota de salida del crs+ al cg
			data["entity"]="cg"
			data["direction"]="salida"
		elsif entities["e1"]=="crs+"
			data["entity"]=entities[:e2]
			data["direction"]="salida"
		elsif entities["e2"]=="crs+"
			data["entity"]=entities[:e1]
			data["direction"]="entrada"
		else
			return error_result
		end
		
		ent = Entity.find_by(sigla: data["entity"])
		
		if ent.nil?
			return error_result
		else
			data["entity"]=ent.id.to_s
		end
		update(protocol: protocol_string, direction: data["direction"], entity: Entity.find(data["entity"]))
		return data 
	end

	def find_related_files()
		related_files = MailFile.find_files(self)
	end

	def get_sources_directory
		dir_path = if entity.sigla=="cg"
			"#{entity.path}/#{(direction=="entrada" ? "ENTRADAS" : "SALIDAS")}/#{date.year}"
		else
			"#{entity.path}/#{date.year}/#{entity.sigla}/#{(direction=="entrada" ? "ENTRADAS" : "SALIDAS")}"
		end
		return (File.directory?(dir_path) ? dir_path : false)
	end

	
	def self.import_worksheet_all(worksheet)
		crs = Entity.find_by(sigla: "crs+")
		headers = ["Nº","Referencia", "From", "To", "Fecha","Asunto", "Contestar", "Ponente", "Respuesta"]
		puts "Reading: #{worksheet.sheet_name}"
		#type_string, entity_sigla = worksheet.sheet_name.split("_")
		#entity = Entity.find_by(sigla: entity_sigla)
		#type = type_string=="Entrada" ? 0 : 1
		rows = worksheet[1..-1].map do |row|
            row.cells.map { |cell| cell.nil? ? '' : cell.value }
        end
        data = rows.map { |row| Hash[headers.zip(row)] }
		data.each_with_index do |row,index|
			puts "rwo from: #{row["From"]} #{row["From"]=="crs+"} to: #{row["To"]}"
			params = 
			{
				date: row["Fecha"],
				topic: row["Asunto"],
				protocol: row["Nº"],
				direction: (row["From"]=="crs+" ? "salida" : "entrada"),
				entity:	(row["From"]=="crs+" ? Entity.find_by(name: row["To"]) : Entity.find_by(name: row["From"])),
				mail_status: ((row["Contestar"]=="si" || row["Contestar"]=="sí") ? "pendiente" : "terminado")
			}
			#return if index > 200 
			mail = Mail.create params
			if !row["Referencia"].blank? && !mail.nil?
				mail.set_references row["Referencia"]
			end
			if !row["Respuesta"].blank? && !mail.nil?
				mail.set_answers row["Respuesta"]
			end
			if !row["Ponente"].blank? && !mail.nil?
				unames = row["Ponente"].split("-").map{|u| u.strip}
				users = unames.map{|user| (User.find_by(uname: user))}
				users = users.select{|user| !user.nil?}
				mail.update(assignedusers: users) unless (users.nil? || users.empty?)
			end
		end
	end

	

	def self.import_from_excel_all(file_path)
		workbook = RubyXL::Parser.parse file_path
    	[0].each do |index| 
			Mail.import_worksheet_all workbook[index]
		end
	end
	
	def self.import_from_excel_update_all(file_path)
		workbook = RubyXL::Parser.parse file_path
    	[0].each do |index| 
			Mail.import_worksheet_update_all workbook[index]
		end
	end
	
	def self.import_worksheet_update_all(worksheet)
		crs = Entity.find_by(sigla: "crs+")
		headers = ["Nº","Referencia", "From", "To", "Fecha","Asunto", "Contestar", "Ponente", "Respuesta"]
		rows = worksheet[1..-1].map do |row|
      row.cells.map { |cell| cell.nil? ? '' : cell.value }
    end
    data = rows.map { |row| Hash[headers.zip(row)] }
		data.each_with_index do |row,index|
			mail = Mail.find_by(protocol: row["Nº"])
			if !row["Referencia"].blank? && !mail.nil?
				mail.set_references row["Referencia"]
			end
			if !row["Respuesta"].blank? && !mail.nil?
				mail.set_answers row["Respuesta"]
			end
		end
	end


	def can_be_deleted?
		true
	end

	def self.get_years()
		min_year = Mail.minimum(:date).year
		current_year = Date.today().year
		(min_year..current_year).to_a
	end
	
	def self.search(params)
		puts "got params in search #{params}"		
		condition = "topic ILIKE '%#{params[:q]}%'" unless params[:q].nil?
    	sets = []
		sets[0] = params[:q].blank? ? Mail.includes(:entity, :assignedusers).all : Mail.includes(:entity).where(condition)
		sets[1] = (params[:year]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where("date_part('year', date)=#{params[:year].to_i}")) 
		sets[2] = (params[:direction]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where(direction: params[:direction]))
		sets[3] = (params[:entity]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where(entity: params[:entity]))
		sets[4] = (params[:mail_status]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where(mail_status: params[:mail_status]))
		sets[5] = (params[:assigned]=="-1" ? nil :  User.find(params[:assigned]).assignedmails.includes(:entity, :assignedusers))
		res = (sets.inject{ |res, set| (set.nil? ? res : res.merge(set)) }).order(date: :desc)
		return res
	end
end #class end

class UnreadMail < ActiveRecord::Base
	belongs_to :mail
	belongs_to :user
end

class AssignedMail < ActiveRecord::Base
	belongs_to 	:mail, :class_name => "Mail"
	belongs_to 	:user, :class_name => "User"
end

class Reference < ActiveRecord::Base
	belongs_to 	:mail, 		:class_name => "Mail"
	belongs_to 	:reference, :class_name => "Mail"

	after_save do
		references = (Reference.where(mail: self.mail).map {|r| r.reference.protocol}).join(", ")
		self.mail.update(refs_string: references)
	end

	after_destroy do
		references = (Reference.where(mail: self.mail).map {|r| r.reference.protocol}).join(", ")
		self.mail.update(refs_string: references)
	end
end

class Answer < ActiveRecord::Base
	belongs_to 	:mail, 		:class_name => "Mail"
	belongs_to 	:answer, 	:class_name => "Mail"

	after_save do
		answers = (Answer.where(mail: self.mail).map {|r| r.answer.protocol}).join(", ")
		mail.update(ans_string: answers)
	end

	after_destroy do
		answers = (Answer.where(mail: self.mail).map {|r| r.answer.protocol}).join(", ")
		self.mail.update(ans_string: answers)
	end
end