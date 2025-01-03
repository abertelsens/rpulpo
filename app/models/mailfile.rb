require 'pandoc-ruby'

# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defininign a file belonging to a mail.
# -----------------------------------------------------------------------------------------



class MailFile < ActiveRecord::Base

	# the objet belongs to a mail object. Each mail_file can have only one mail file of a given name
	belongs_to  :mail
	validates 	:name, uniqueness: { scope: :mail_id }

	TMP_DIR = "app/public/tmp/mail"
	PUBLIC_TMP_DIR = "/tmp/mail"

	# -----------------------------------------------------------------------------------------
	# CRUD
	# -----------------------------------------------------------------------------------------

   # creates a MailFile object given a file and a mail object.
	def self.create_from_file(file, mail)
		extension = File.extname(File.basename(file))
		path = "#{mail.get_sources_directory}/#{file}"
		# create the mail file
		mf = MailFile.create(mail: mail, name: file, extension: extension, mod_time: File.mtime(path))
		# update the html contents
		mf.update(html: mf.get_html_contents) if mf.is_word_file?
	end

	# -----------------------------------------------------------------------------------------
	# ACCESSORS
	# -----------------------------------------------------------------------------------------

  def get_path
    "#{mail.get_sources_directory}/#{name}"
  end

	# gets the html of the file. We first check if the html field is up to date.
	# @returs [string] The html contents fo the file.
	def get_html
		update_html
		html
	end

	# pandoc needs a complete dir of the network to work, otherwise it will not be able
	# to find the file. File paths which containt spaces make trouble, therefore we need
	# to wrap them around quotation marks.
	# Embedded media, like images, will be stored in the public/tmp/media/ directory
	def	get_html_contents()
		if is_word_file?
			html_string = `pandoc --email-obfuscation=none --extract-media tmp \"#{get_path}\" --from docx --to html`
			#puts clean_html html_string
			clean_html html_string
		else
			"<p> could not parse document"
		end
	end

	# pandoc needs a complete dir of the network to work, otherwise it will not be able
	# to find the file. File paths which containt spaces make trouble, therefore we need
	# to wrap them around quotation marks.
	# Embedded media, like images, will be stored in the public/tmp/media/ directory
	def	get_text_contents()
		if is_word_file?
			`pandoc --email-obfuscation=none \"#{get_path}\" --from docx --to plain`
			#puts clean_html html_string
		else
			"could not parse document"
		end
	end

		# pandoc needs a complete dir of the network to work, otherwise it will not be able
	# to find the file. File paths which containt spaces make trouble, therefore we need
	# to wrap them around quotation marks.
	# Embedded media, like images, will be stored in the public/tmp/media/ directory
	def	get_md_contents()
		if is_word_file?
			`pandoc --email-obfuscation=none \"#{get_path}\" --from docx --to markdown`
		else
			"could not parse document"
		end
	end

	def clean_html(html_string)
		html_string.gsub(/<script.*?>(.+?)<\/script>/, '\1').gsub(/<noscript.*?>(.+?)<\/noscript>/, '\1')
	end

	# gets the pdf path of a mail_file. Used to preview an annexes.
	def	get_pdf_path
		# Delete all the files in the tmp folder that are older than one day
		Dir.glob("#{TMP_DIR}/*.pdf").each { |filename| File.delete(filename) if file_age(filename) > 0 }
		original_file = "#{mail.get_sources_directory}/#{name}"
		FileUtils.cp(original_file, "#{TMP_DIR}/#{name}")
		"#{PUBLIC_TMP_DIR}/#{name}"
	end

	# returns the file age in days
	def file_age(name)
		(Time.now - File.ctime(name))/(24*3600)
	end

	def is_word_file?
		[".docx", ".doc"].include? extension
	end

  def is_pdf_file?
		[".pdf"].include? extension
	end

	# updates the html field is the file in the file system has been modified.
	def update_html
		update(html: get_html_contents, mod_time: Time.now)	if (is_word_file? && (has_been_modified? || html==nil))
	end

	# checks whether the modification time of the file in the file system is later
	# than the version we have in the db. If we have no modification time in the db
	# we return true.
	def has_been_modified?
		if mod_time then (File.mtime(get_path) > mod_time)
		else
			update(mod_time: File.mtime(get_path))
			true
		end
	end
end	#class end
