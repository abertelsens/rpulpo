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
	has_many 	:unreadmails, dependent: :destroy, class_name: 'UnreadMail'
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
			date:			Date.today,
			topic:			"",
			protocol:		"crs+ XX/XX",
			direction:		0,	
			mail_status:	0	
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
		mail = Mail.create(prepare_params params)
		User.where(mail:true).each {|user| UnreadMail.create(mail_id: mail.id, user_id:user.id)} 
		return mail
	end

	# return an array of mail objects given a string of the type "prot1, prot2"
	def self.find_mails(protolos_string)
		protolos_string.split(",").map{|prot| Mail.find_by(protocol: prot.strip)}
	end

	def update_from_params(params)
		set_assigned_users(params[:assigned])
		set_references(params[:references])
		set_answers(params[:answers])
		update(Mail.prepare_params params)
	end
	
	# users arry contains an array of users ids
	def set_answers(answers_string)
		answers = Mail.find_mails answers_string
		answers==[] ? answers.destroy_all : update(ans: answers)
	end

	# users arry contains an array of users ids
	def set_references(references_string)
		references = Mail.find_mails references_string
		references==[] ? self.references.destroy_all : self.update(refs: references)
	end

	# checks if a given protocols string contains exisiting mails. 
	def check_protocols(protocols_string)
		return {result: true, data: nil} if protocols_string.strip.empty?
		mails = Mail.find_mails protocols_string
		r = mails.map{|mail| {protocol: protocol, status: mail!=nil} }
		res = r.map{|elem| elem[:status]}.inject(:&)
		{result: res, data: r}
	end

	
	# users arry contains an array of users ids
	def set_assigned_users(users_array)
		users_array.nil? ? AssignedMail.where(mail: self).destroy_all : update(assignedusers: User.find(users_array))
	end

	# users arry contains an array of users ids
	def get_assigned_users()
		assignedusers.pluck(:uname).join("-")
	end

	# users arry contains an array of users ids
	def get_references()
		res.pluck(:protocol).join("-")
	end

	def send_related_files_to_users(users)
		set_assigned_users users.split(",")
		assignedusers.each {|u| (send_related_files_to_user u)} unless (users.nil? || users.blank?)
	end

	def send_related_files_to_user(user)
		balda = "#{BALDAS_BAS_DIR}/#{user.uname}"
		files = mail_files.map{|mf| [mf.get_original_path, mf.name]}
		if files.size==1
			puts Rainbow("Copying #{files[0][0]} to #{balda}/#{user.uname}-#{files[0][1]}").yellow
			res = FileUtils.cp(files[0][0],"#{balda}/#{user.uname}-#{files[0][1]}")
		else
			new_dir = "#{balda}/#{user.uname}-#{protocol.gsub("/","-")}"
			FileUtils.mkdir new_dir unless Dir.exist? new_dir

		files.each do |f| 
			puts Rainbow("Copying #{f[0]} to #{new_dir}/#{f[1]}").yellow
			FileUtils.cp(f[0],"#{new_dir}/#{f[1]}")
		end
	end
	
end
	# tries to suggest a direction and the entity fields from a protocol
	def update_protocol(protocol_string)
		data = {"result" => true, "entity" => nil, "direction"=> nil, "message"=>""}
		num = protocol_string.match(/(?<num>[0-9]+)\/(?<year>[0-9]{2})/)
		entities = protocol_string.match(/(?<e1>[a-zA-Z]+\+*)\s*-*\s*(?<e2>[a-zA-Z]*\+*)/)
		
		if num.nil? 
			data["result"]=false
			data["message"]="El protocolo <b>#{protocol_string}</b> está mal formado" 
			return data
		end

		puts "entities #{entities} **#{entities[:e1]}** **#{entities[:e2]}**" unless entities.nil?
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
			data["result"]=false
			data["message"]="El protocolo <b>#{protocol_string}</b> está mal formado" 
			return data
		end
		
		puts "trying to find entity by sigla"
		ent = Entity.find_by(sigla: data["entity"])
		
		if ent.nil?
			puts "did not find any entity with sigla #{data["entity"]}"
			data["result"]=false
			data["message"]="El protocolo <b>#{protocol_string}</b> está mal formado." 
			return data
		else
			puts "Found entity #{ent.id.to_s}"
			data["result"]=true
			data["entity"]=ent.id.to_s
		end
		update(protocol: protocol_string, direction: data["direction"], entity: Entity.find(data["entity"]))
		return data 
	end

	def find_related_files()
		protocol_num = protocol[0..-4].delete("^0-9").to_i	
		files = Dir.entries(get_sources_directory).select{ |fname| Mail.matches_file(fname, protocol_num)}
		mfiles = []
		files = files.each do |f| 
				mf = MailFile.where(mail_id: id, name: f)
				mfiles << (mf.empty? ? MailFile.create_from_file(f,self) : mf[0])  
		end
		return mfiles
	end


	# we check not only the files related to the protocol but also references and answers
	def self.matches_file(file_name, prot_num)
		match = /\d+/.match(file_name)
		match.nil? ? false : (match[0].to_i == prot_num)
	end
	
	def get_sources_directory
		dir_path = if entity.sigla=="cg"
			"#{entity.path}/#{(direction=="entrada" ? "ENTRADAS" : "SALIDAS")}/#{date.year}"
		else
			"#{entity.path}/#{date.year}/#{entity.sigla}/#{(direction=="entrada" ? "ENTRADAS" : "SALIDAS")}"
		end
		return (File.directory?(dir_path) ? dir_path : false)
	end


	def can_be_deleted?
		true
	end

	def self.get_years()
		min_year = Mail.minimum(:date).year
		current_year = Date.today().year
		(min_year..current_year).to_a
	end
	
	def get_status
		return mail_status
	end

	def self.search(params)
		puts "got params in search #{params}"		
		condition1 = "topic ILIKE '%#{params[:q]}%'" unless params[:q].nil?
		condition2 = "protocol ILIKE '%#{params[:q]}%'" unless params[:q].nil?
		sets = []
		sets[0] = params[:q].blank? ? Mail.includes(:entity, :assignedusers).all : Mail.includes(:entity).where(condition1)		
		sets[0] = params[:q].blank? ? Mail.includes(:entity, :assignedusers).all : Mail.includes(:entity).where(condition1).or(Mail.includes(:entity).where(condition2))		
		sets[1] = (params[:year]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where("date_part('year', date)=#{params[:year].to_i}")) 
		sets[2] = (params[:direction]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where(direction: params[:direction]))
		sets[3] = (params[:entity]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where(entity: params[:entity]))
		sets[4] = (params[:mail_status]=="-1" ? nil :  Mail.includes(:entity, :assignedusers).where(mail_status: params[:mail_status]))
		sets[5] = (params[:assigned]=="-1" ? nil :  User.find(params[:assigned]).assignedmails.includes(:entity, :assignedusers))
		(sets.inject{ |res, set| (set.nil? ? res : res.merge(set)) }).order(date: :desc)
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

class UnreadMail < ActiveRecord::Base
	belongs_to 	:mail, 		:class_name => "Mail"
	belongs_to 	:user, 		:class_name => "User"
end