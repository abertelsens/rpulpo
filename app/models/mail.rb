# mail.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class defining a mail object
# -----------------------------------------------------------------------------------------
TAB = "\u0009".encode('utf-8')

class Mail < ActiveRecord::Base

	BASE_DIR= "app/public"
	BALDAS_BAS_DIR = "/mnt/sect/CORREO-CG/BALDAS"
	#BALDAS_BAS_DIR = "L:/Usuarios/sect/CORREO-CG/BALDAS"
	BASE_PATH = "/mnt/sect"
	#BASE_PATH = "L:/Usuarios/sect"
	CRSC = "crs+"
	DEFAULT_PROTOCOL = "crs+ XX/XX"

	enum direction:    		{ entrada: 		0, salida: 		1}
	enum mail_status:    	{ pendiente: 	0, en_curso: 	1, terminado: 2 }

	belongs_to 	:entity

	has_many		:assigned_mails, 	dependent: :destroy
	has_many 		:assigned_users, 	:through => :assigned_mails, 	:source => :user, 		dependent: :destroy
	has_many 		:references, 			dependent: :destroy
	has_many 		:answers, 				dependent: :destroy
	has_many 		:mail_files, 			dependent: :destroy
	has_many 		:refs,						:through => :references, 			:source => :reference
	has_many 		:ans,							:through => :answers, 				:source => :answer

	# the default scoped defines the default sort order of the query results
	default_scope { order(date: :desc, protocol: :desc) }

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------

	# after a mail object is created we add it to the unreadmails table to each one of the
	# mail users
	after_create :mark_as_unread

# -----------------------------------------------------------------------------------------
# CRUD
# -----------------------------------------------------------------------------------------

	# prepares params after receiving them from the form.
	def self.prepare_params(params=nil)
		if params.nil? # no params provided. We create default params
			{
				entity: 		Entity.find_by(sigla: CRSC),
				date:				Date.today,
				topic:			"",
				protocol:		DEFAULT_PROTOCOL,
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

	# afer updating the mail fields we update the associations: assigned users, references and answers.
	# The assigned users array coming form the form might be nil, in this case we pass an empty array.
	def update_from_params(params)
		update(Mail.prepare_params params)
		update_association_elements( (params[:assigned].nil? ? [] : params[:assigned]), :assigned_users)
		update_association(params[:references], :references)
		update_association(params[:answers], :answers)
	end


# -----------------------------------------------------------------------------------------
# ASSOCIATIONS
# -----------------------------------------------------------------------------------------
	# returns a hash with the resutls of the update operation
	def update_association(protocols_string, association)
		protocols_string = protocols_string.strip

		# if the protocol string is empty
		if (protocols_string.nil? || protocols_string.blank?)
			update_association_elements([],association)
			update(ans_string: nil)
			return {result: true, data: nil}
		end

		protocols_array = protocols_string.split(",")
		new_elements =  Mail.find_mails protocols_string
		protocols_hash = new_elements.map.with_index do |mail,index|
			{
				protocol: (mail.nil? ? protocols_array[index] : mail.protocol),
				status: 	mail!=nil
			}
		end
		result = new_elements.include?(nil) ? false : true
		new_elements = new_elements.select{ |ref| !ref.nil? } # eliminate all the nil results
		update_association_elements(new_elements.pluck(:id), association) unless new_elements[0].nil?

		case association
			when :answers 		then update(ans_string: new_elements.pluck(:protocol).join(", "))
			when :references 	then update(refs_string: new_elements.pluck(:protocol).join(", "))
		end
		{ result: result, data: protocols_hash }

	end

	# users array contains an array of users ids
	def update_association_elements(elements_array, association)

		new_elements = elements_array.map{|element_id| element_id.to_i} unless elements_array.nil?

		current_elements =
		case association
			when :assigned_users 	then assigned_users.pluck(:id)
			when :answers 				then answers.pluck(:answer_id)
			when :references 			then references.pluck(:reference_id)
		end

		elements_to_delete = (current_elements.nil? ? nil : (new_elements.nil? ? current_elements : (current_elements-new_elements) ) )
		elements_to_add = (new_elements.nil? ? nil : (current_elements.nil? ? new_elements : (new_elements-current_elements) ) )

		case association
		when :assigned_users
			AssignedMail.where(mail: self, user_id: elements_to_delete).delete_all
			AssignedMail.create(elements_to_add.map{|user_id| {mail: self, user_id: user_id} })
		when :answers
			Answer.where(mail: self, answer: elements_to_delete).delete_all
			Answer.create(elements_to_add.map{|answer_id| {mail: self, answer_id: answer_id} })
		when :references
			Reference.where(mail: self, reference: elements_to_delete).delete_all
			Reference.create(elements_to_add.map{|reference_id| {mail: self, reference_id: reference_id} })
		end
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
		next_prot_number = (mails.map {|mail| mail.get_protocol_serial }).max + 1
		"crs+#{entity.sigla=="cg" ? "" : "-"+entity.sigla} #{next_prot_number}/#{current_year-2000}"
	end

	# given a protocol returns the numeric part of the protocol without the par corresponding to the year
	# for example: for a mail with protocol "crs+ 56/24" the result will be 56 (int)
	def get_protocol_serial()
		m = protocol.match(/(?<num>[0-9]+)\/(?<year>[0-9]{2})/)
		return 0 if m.nil?
		m[:num].to_i
	end

	# users arry contains an array of users ids
	def get_assigned_users()
		assigned_users.pluck(:uname).join("-")
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
		{result: true}.to_json
	end

	# tries to suggest a direction and the entity fields from a protocol
	def update_protocol(protocol_string)
		data 	= { result: true }
		error = { result: false, message: "El protocolo <b>#{protocol_string}</b> está mal formado" }

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

	# finds all the related files of the mail
	# @returs [[mailfile]]: an array of mailfiles objects mailfile
	def find_related_files()
		protocol_num = protocol[0..-4].delete("^0-9").to_i
		begin
			files = Dir.entries(get_sources_directory).select{ |fname| Mail.matches_file(fname, protocol_num)}
			files = files.sort{|f1, f2| Mail.file_sort(f1,f2)}
			current_files = mail_files.pluck(:name)
			(current_files - files).each {|file| MailFile.find_by(mail: self, name: file).destroy }
			(files - current_files).each {|file| MailFile.create_from_file(file, self) }
			mail_files
		rescue
			nil
		end
	end

	def self.file_sort(f1,f2)
		f1_name, f1_ext = f1.split(".")
		f2_name, f2_ext = f2.split(".")
		if (f1_name.include? f2_name) 		then 1
		elsif (f2_name.include? f1_name) 	then -1
		else f1 <=> f2
		end
	end

	# check whether a file with name file_name contains the numerical part of the protocol
	# @file_name 	[String]: 	the name of the file
	# @prot_num 	[String]: 	the numerical part of the protocol
	# @returns 		[Boolean]: 	whether there is a match
	def self.matches_file(file_name, prot_num)
		return false if (file_name[0]=="." || file_name[0]=="~")	# skip temporary or hidden files that
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
		(min_year..current_year).to_a.reverse
	end

	def get_status
		mail_status
	end

	def prepare_text(user)
		users = ["sect", "vr", "r"] if user.uname=="sect"
		users = ["vr", "sect", "r"] if user.uname=="vice"
		users = ["r", "sect", "vr"] if user.uname=="rector"

		css = "<style>
					table {border: 1px solid black; border-collapse: collapse; width:100%}\n
					td {width:20%}\n
					</style>\n"

		# add the signature boxes
		html = css << "<table><tr><td>#{users[0]}<br>»</td><td>#{users[1]}<br>»</td><td>#{users[2]}<br>»</td><td><br>»</td><td><br>»</td></tr></table>\n"
		html << "<h2>Asunto: #{topic}</h2>\n"

		# add the references
		html << "<h2>Antecedentes:</h2>\n"
		html = refs.inject(html){ |res,ref| (res << "<blockquote>#{ref.mail2html}</blockquote>\n") } unless refs.nil?
		html << "- - -<br>"

		# the header of the draft. It includes the references and the protocol
		references_string = refs.empty? ? "" : "Ref. #{refs_string}"
		header = "<p>#{references_string}     #{protocol}</p>"
		body = "<ol><li><p>Agradecemos...<p></li></ol>"
		footer = "<p>Roma, #{Time.now.strftime("%d-%m-%y")}</p>"
		res = html << header << body << footer
		puts res
		res
	end

	# provides an html text of the files related to the mail object.
	def mail2html
			find_related_files.inject("<h3>#{protocol}</h3>\n"){|res, mf|  (res << (mf.get_html_contents) << "\n") }
	end

	def self.search(params)
		condition1 = "topic ILIKE '%#{params[:q]}%'" unless params[:q].nil?
		condition2 = "protocol ILIKE '%#{params[:q]}%'" unless params[:q].nil?
		sets = []
		sets[0] = params[:q].blank? ? Mail.includes(:entity, :assigned_users).all : Mail.includes(:entity).where(condition1)
		sets[0] = params[:q].blank? ? Mail.includes(:entity, :assigned_users).all : Mail.includes(:entity).where(condition1).or(Mail.includes(:entity).where(condition2))
		sets[1] = (params[:year]=="-1" ? nil :  Mail.includes(:entity, :assigned_users).where("date_part('year', date)=#{params[:year].to_i}"))
		sets[2] = (params[:direction]=="-1" ? nil :  Mail.includes(:entity, :assigned_users).where(direction: params[:direction]))
		sets[3] = (params[:entity]=="-1" ? nil :  Mail.includes(:entity, :assigned_users).where(entity: params[:entity]))
		sets[4] = (params[:mail_status]=="-1" ? nil :  Mail.includes(:entity, :assigned_users).where(mail_status: params[:mail_status]))
		sets[5] = (params[:assigned]=="-1" ? nil :  User.find(params[:assigned]).assignedmails.includes(:entity, :assigned_users))
		sets.inject{ |res, set| (set.nil? ? res : res.merge(set)) }
	end
end #class end

def mark_as_unread
	UnreadMail.create(User.mail_users.map {|user| {user: user, mail: self} })
end
# -----------------------------------------------------------------------------------------
# ASSOCIATED CLASSES
# -----------------------------------------------------------------------------------------

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
