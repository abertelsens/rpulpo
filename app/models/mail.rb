# -----------------------------------------------------------------------------------------
# A class defining a mail object
# -----------------------------------------------------------------------------------------

class Mail < ActiveRecord::Base

	BASE_DIR= "app/public"
	BALDAS_BAS_DIR = "/mnt/sect/CORREO-CG/BALDAS"
	#BALDAS_BAS_DIR = "L:/usuarios/sect/CORREO-CG/BALDAS"
	#BASE_PATH = "//rafiki.cavabianca.org/datos/usuarios/sect"
	BASE_PATH = "/mnt/sect"

	enum direction:    		{ entrada: 0, salida: 1}
	enum mail_status:    	{ pendiente: 0, en_curso: 1, terminado: 2 }

	belongs_to 	:entity
	has_many 	:assigned_mails, dependent: :destroy
	has_many 	:assignedusers, :through => :assigned_mails, :source => :user, dependent: :destroy
	has_many 	:references, dependent: :destroy
	has_many 	:refs,	:through => :references, 	:source => :reference
	has_many 	:answers, dependent: :destroy
	has_many 	:ans,	:through => :answers, :source => :answer
	has_many 	:mail_files, dependent: :destroy

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------

	after_create do |mail|
		User.get_mail_users.each{|user| UnreadMail.create(user: user, mail: mail)}
	end

# -----------------------------------------------------------------------------------------
# CRUD
# -----------------------------------------------------------------------------------------

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

	def self.create_from_params(params=nil)
		Mail.create(prepare_params params)
	end

	def update_from_params(params)
		update(assignedusers: (User.find params[:assigned])) unless params[:assigned].nil?
		update_references(params[:references])
		update_answers(params[:answers])
		update(Mail.prepare_params params)
	end

	# checks if a given protocols string contains exisiting mails.
	def update_references(protocols_string)
		if protocols_string.strip.blank?
			references.destroy_all
			update(refs_string: "")
			return {result: true}
		end
		mails = Mail.find_mails protocols_string
		r = mails.map{|mail| {protocol: protocol, status: mail!=nil} }
		res = r.map{|elem| elem[:status]}.inject(:&)
		update(refs: mails, refs_string: mails.pluck(:protocol).join(", ")) if res
		if res
			mails.each do |mail|
				old_answers =  mail.ans_string
				new_answers = (old_answers.blank? ? protocol : old_answers + ", " + protocol)
				mail.update_answers new_answers
			end
		end
		{result: res, data: r}
	end

	# checks if a given protocols string contains exisiting mails.
	def update_answers(protocols_string)
		puts Rainbow("updating answer to #{protocols_string}").purple
		if protocols_string.blank?
			answers.destroy_all
			update(ans_string: "")
			return {result: true}
		end
		mails = Mail.find_mails protocols_string
		r = mails.map{|mail| {protocol: protocol, status: mail!=nil} }
		res = r.map{|elem| elem[:status]}.inject(:&)
		update(ans: mails, ans_string: mails.pluck(:protocol).join(", ")) if res
		{result: res, data: r}
	end

	# users arry contains an array of users ids
	def set_assigned_users(users_array)
		users_array.nil? ? AssignedMail.where(mail: self).destroy_all : update(assignedusers: User.find(users_array))
	end

# -----------------------------------------------------------------------------------------
# ACCESSORS
# -----------------------------------------------------------------------------------------

	# return an array of mail objects given a string of the type "prot1, prot2"
	def self.find_mails(protocols_string)
		protocols_string.split(",").map{|prot| Mail.find_by(protocol: prot.strip)}.uniq
	end

	# given an entity suggest the next protocol for an outgoing mail to that entity
	def self.assign_protocol(entity)
		current_year = Date.today.year
		# get all the outgoing mails from the entity this year
		mails = Mail.where(entity: entity, direction: "salida").and(Mail.where("date_part('year', date)=#{current_year}"))
		protocols = mails.map {|mail| mail.get_protocol_serial[0].to_i }
		"crs+#{entity.sigla=="cg" ? "" : "-"+entity.sigla} #{protocols.max + 1}/#{current_year-2000}"
	end

	# given a protocol retuns and array with the numers corresponding to the number and the year
	# for example: for a mail with protocol "crs+ 56/24" the result will be [56,24]
	def get_protocol_serial()
		m = protocol.match(/(?<num>[0-9]+)\/(?<year>[0-9]{2})/)
		return [-1,-1] if m.nil?
		[m[:num].to_i,m[:year].to_i]
	end

	# users arry contains an array of users ids
	def get_assigned_users()
		assignedusers.pluck(:uname).join("-")
	end

	# users arry contains an array of users ids
	def get_references()
		res.pluck(:protocol).join("-")
	end

	def send_related_files_to_users(users_string)
		set_assigned_users users_string.split(",")
		assignedusers.each {|u| (send_related_files_to_user u)} unless (assignedusers.nil? || assignedusers.blank?)
	end

	def send_related_files_to_user(user)
		target = "#{BALDAS_BAS_DIR}/#{user.uname}"
		mail_files = find_related_files

		# if we need to send more than one file we create a directory and send the mails there
		if (mail_files.size>1)
			target = "#{target}/#{user.uname}#{protocol.gsub("/","-")}"
			FileUtils.mkdir target unless Dir.exist? target
		end

		mail_files.each {|mf| FileUtils.cp mf.get_path, "#{target}/#{user.uname}-#{mf.name}" }

	end

	# tries to suggest a direction and the entity fields from a protocol
	def update_protocol(protocol_string)
		data = { "result" => true }
		error = { "result" => false, "message" => "El protocolo <b>#{protocol_string}</b> está mal formado" }

		# check if the numeric part of the protocol is well formed
		num = protocol_string.match(/(?<num>[0-9]+)\/(?<year>[0-9]{2})/)
		return error if num.nil?

		entities = protocol_string.match(/(?<e1>[a-zA-Z]+\+*)\s*-*\s*(?<e2>[a-zA-Z]*\+*)/)

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
			return error
		end

		ent = Entity.find_by(sigla: data["entity"])
		return error if ent.nil?

		data["entity"]=ent.id.to_s
		update(protocol: protocol_string, direction: data["direction"], entity: ent)
		data
	end

	def find_related_files()
		protocol_num = protocol[0..-4].delete("^0-9").to_i
		files = Dir.entries(get_sources_directory).select{ |fname| Mail.matches_file(fname, protocol_num)}
		files = files.sort{|f1, f2| Mail.file_sort(f1,f2)}
		mfiles = []
		files = files.each do |f|
				mf = MailFile.where(mail_id: id, name: f)
				mfiles << (mf.empty? ? MailFile.create_from_file(f,self) : mf[0])
		end
		update(mail_files: mfiles)
		return mfiles
	end

	def self.file_sort(f1,f2)
		f1_name, f1_ext = f1.split(".")
		f2_name, f2_ext = f2.split(".")
		if (f1_name.include? f2_name)
			1
		elsif (f2_name.include? f1_name)
			-1
		else
			f1 <=> f2
		end
	end

	# we check not only the files related to the protocol but also references and answers
	def self.matches_file(file_name, prot_num)
		return false if (file_name[0]=="." || file_name[0]=="~")
		match = /\d+/.match(file_name)
		match.nil? ? false : (match[0].to_i == prot_num)
	end

	def get_sources_directory
		base = "#{BASE_PATH}/#{entity.path}"
		dir_path = if entity.sigla=="cg"
			"#{base}/#{(direction=="entrada" ? "ENTRADAS" : "SALIDAS")}/#{date.year}"
		else
			"#{base}/#{date.year}/#{entity.sigla}/#{(direction=="entrada" ? "ENTRADAS" : "SALIDAS")}"
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
		(sets.inject{ |res, set| (set.nil? ? res : res.merge(set)) }).order(date: :desc, protocol: :desc)
	end
end #class end

class UnreadMail < ActiveRecord::Base
	belongs_to :mail
	belongs_to :user
end

class AssignedMail < ActiveRecord::Base
	belongs_to 	:mail
	belongs_to 	:user
end

class Reference < ActiveRecord::Base
	belongs_to 	:mail
	belongs_to 	:reference, :class_name => "Mail"
end

class Answer < ActiveRecord::Base
	belongs_to 	:mail, 		:class_name => "Mail"
	belongs_to 	:answer, 	:class_name => "Mail"
end

class UnreadMail < ActiveRecord::Base
	belongs_to 	:mail
	belongs_to 	:user
end
