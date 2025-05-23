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
require 'os'

TAB = "\u0009".encode('utf-8')

class Mail < ActiveRecord::Base

	BASE_DIR					= "app/public"
	BALDAS_BASE_DIR 	= OS.windows? ? "L:/Usuarios/sect/CORREO" : "/mnt/sect/CORREO"
	BASE_PATH 				= OS.windows? ? "L:/Usuarios/sect/CORREO" :  "/mnt/sect/CORREO"
	CRSC 							= "crs+"
	DEFAULT_PROTOCOL 	= "crs+ XX/XX"

	enum :direction,    		{ entrada: 		0, salida: 		1}
	enum :mail_status,    	{ pendiente: 	0, en_curso: 	1, terminado: 2 }

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

	scope :with_entity, 		-> (entity) 		{ includes(:entity, :assigned_users).where(entity: entity) }
	scope :with_direction, 	-> (direction) 	{ includes(:entity, :assigned_users).where(direction: direction) }
	scope :with_status, 		-> (status) 		{ includes(:entity, :assigned_users).where(mail_status: status) }
	scope :is_assigned_to, 	-> (user) 			{ includes(:entity, :assigned_users).joins(:assigned_mails).where(assigned_mails: {user: user}) }
	scope :with_year, 			-> (year) 			{ includes(:entity, :assigned_users).where("date_part('year', date)=#{year}") }

# -----------------------------------------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------------------------------------

	# after a mail object is created we add it to the unreadmails table to each one of the
	# mail users
	after_create :mark_as_unread

	def mark_as_unread
		UnreadMail.create(User.mail_users.map {|user| {user: user, mail: self} })
	end

# -----------------------------------------------------------------------------------------
# CRUD
# -----------------------------------------------------------------------------------------

	# prepares params after receiving them from the form.
	def self.prepare_params(params=nil)
		if params.nil? # no params provided. We create default params
			{
				entity: 			Entity.find_by(sigla: "cg"),
				date:					Date.today,
				topic:				"",
				protocol:			"XX/#{Time.now.year.to_s[2..3]}",
				direction:		"entrada",
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

	def self.create_from_params(params=nil)
		Mail.create(prepare_params params)
	end

	# after updating the mail fields we update the associations: assigned users, references and answers.
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

		# make sure the protocol string is clean of blank spaces
		protocols_string = protocols_string.strip

		# Find all the mails that correspond to the protocols string that was
		# received.
		protocols_array  = protocols_string.split(",").map{|s| s.strip }
		elements = (protocols_string.blank? ? [] : Mail.find_mails(protocols_string))
		elements_hash = elements.map.with_index do |mail, index|
			{
				protocol: (mail.nil? ? protocols_array[index] : mail.protocol),
				status: 	mail!=nil
			}
		end

		# if there is a nil element then there was an error.
		return {result: false, data: elements_hash} if (elements.include? nil)

		update_association_elements(elements.pluck(:id), association)
		case association
			when :answers 		then update(ans_string: elements.pluck(:protocol).join(", "))
			when :references 	then update(refs_string: elements.pluck(:protocol).join(", "))
		end
		return {result: true, data: nil}

	end

	# users array contains an array of mail ids or users ids
	def update_association_elements(elements, association)
		case association
		when :assigned_users 	then self.assigned_users = User.find(elements)
		when :answers 				then self.ans = Mail.find(elements)
		when :references 			then self.refs = Mail.find(elements)
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
		max_prot_number = (mails.map {|mail| mail.get_protocol_serial }).max
		next_prot_number = (max_prot_number.nil? ? 1 : max_prot_number + 1 )
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

	# tries to suggest a direction and the entity fields from a protocol
	def update_protocol(protocol_string)
		data 	= { result: true }
		error = { result: false, message: "El protocolo <b>#{protocol_string}</b> está mal formado" }

		# check if the numeric part of the protocol is well formed
		num = protocol_string.match(/(?<num>[0-9]+)\/(?<year>[0-9]{2})/)
		return error if num.nil?

		entities = protocol_string.match(/(?<e1>[a-zA-Z]+\+*)\s*-*\s*(?<e2>[a-zA-Z]*\+*)/)

		case
		when entities.nil? # No entity present, default to "cg"
			data["entity"] = "cg"
			data["direction"] = "entrada"
		when entities[:e2].blank? && entities[:e1] == "crs+" # Outgoing from "crs+" to "cg"
			data["entity"] = "cg"
			data["direction"] = "salida"
		when entities[:e1] == "crs+" # General outgoing from "crs+"
			data["entity"] = entities[:e2]
			data["direction"] = "salida"
		when entities[:e2] == "crs+" # General incoming to "crs+"
			data["entity"] = entities[:e1]
			data["direction"] = "entrada"
		else
			return error
		end

		ent = Entity.find_by(sigla: data["entity"])
		return error if ent.nil?

		data["entity"]=ent.id.to_s
		update(protocol: protocol_string, direction: data["direction"], entity: ent)
		data
	end

	# finds all the related files of the mail. If no files are found the method returns an empty array/
	# @returs [[mail_file]]: an array of mail_files objects mail_file.
	#
	def find_related_files()
		protocol_num = protocol[0..-4].delete("^0-9").to_i
		source_dir = get_sources_directory
		return [] unless source_dir
		files = Dir.entries(source_dir).select{ |fname| Mail.matches_file(fname, protocol_num)}

		current_files = mail_files.pluck(:name)
		(current_files - files).each {|file| MailFile.find_by(mail: self, name: file).destroy }
		(files - current_files).each {|file| MailFile.create_from_file(file, self) }
		mail_files.nil? ? [] : mail_files.to_a.sort{|f1, f2| Mail.file_sort(f1,f2)}
	end

	def self.file_sort(f1,f2)
		f1_name, f1_ext = f1.name.split(".")
		f2_name, f2_ext = f2.name.split(".")
		return f1_name <=> f2_name
	end

	# check whether a file with name file_name contains the numerical part of the protocol
	# @file_name 	[String]: 	the name of the file
	# @prot_num 	[String]: 	the numerical part of the protocol
	# @returns 		[Boolean]: 	whether there is a match
	def self.matches_file(file_name, prot_num)
		#puts "looking for march of #{file_name} and #{prot_num}"
		return false if (file_name[0]=="." || file_name[0]=="~")	# skip temporary or hidden files that
		match = /\d+/.match(file_name)
		match.nil? ? false : (match[0].to_i == prot_num)
	end

	def get_sources_directory
		#puts "gettings sources dir. Base path"
		base = "#{BASE_PATH}/#{entity.nil? ? "" : entity.path}"
		base = base.sub(/\/\z/, '')
		#puts base
		dir_path =  "#{base}/#{entity.nil? ? "" :  entity.sigla}/#{(direction=="entrada" ? "ENTRADAS" : "SALIDAS")}/#{date.year}"
		#puts dir_path
		(File.directory?(dir_path) ? dir_path : false)
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

	# provides an html text of the files related to the mail object.
	def mail2html
			find_related_files.inject("<h3>#{protocol}</h3>\n"){|res, mf|  (res << mf.get_contents(:html) << "\n") }
	end

	def self.search(params)
		query = Mail.includes(:entity, :assigned_users)

		if params[:q].present?
			search_term = "%#{params[:q]}%"
			query = query.where("topic ILIKE ? OR protocol ILIKE ?", search_term, search_term)
		end

		filters = {
			year: ->(val) { Mail.with_year(val.to_i) },
			direction: ->(val) { Mail.with_direction(val) },
			entity: ->(val) { Mail.with_entity(val) },
			mail_status: ->(val) { Mail.with_status(val) },
			assigned: ->(val) { Mail.is_assigned_to(val) }
		}

		filters.each do |key, scope|
			query = query.merge(scope.call(params[key])) if params[key].present?
		end

		query
	end

	def draft_writer(user)
		WordWriter.new(self, user)
	end

end #class end


# -----------------------------------------------------------------------------------------
# ASSOCIATED CLASSES
# -----------------------------------------------------------------------------------------

class UnreadMail < ActiveRecord::Base
	belongs_to :mail
	belongs_to :user
end # class end

class AssignedMail < ActiveRecord::Base
	belongs_to 	:mail
	belongs_to 	:user
end # class end

class Reference < ActiveRecord::Base
	belongs_to 	:mail
	belongs_to 	:reference, :class_name => "Mail"

	# after a reference is added we update tht corresponding answer
	after_create :update_answer

	def update_answer
		answer = Answer.create(mail: reference, answer:mail)
	end
end # class end

class Answer < ActiveRecord::Base
	belongs_to 	:mail
	belongs_to 	:answer, 		:class_name => "Mail"

	after_create :update_answer_string

	def update_answer_string
		mail.update(ans_string: mail.ans.pluck(:protocol).join(", "))
	end

end # class end
