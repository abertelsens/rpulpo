require 'pandoc-ruby'

# -----------------------------------------------------------------------------------------
# DESCRIPTION
# A class defininign a file belonging to a mail.
# -----------------------------------------------------------------------------------------


class MailFile < ActiveRecord::Base

	# the objet belongs to a mail object. Each mailfile can have only one mail file of a given name
	belongs_to  :mail
	validates 	:name, uniqueness: { scope: :mail_id }

	#enum :file_type: {nota: 0, reference: 1, answer: 2}

   # creates a MailFile object given a file and a mail object.
	def self.create_from_file(file, mail)
		extension = File.extname(File.basename(file))
		MailFile.create(mail: mail, name: file, extension: extension)
	end

  def get_path
		puts "returning path #{mail.get_sources_directory}/#{name}"
    return "#{mail.get_sources_directory}/#{name}"
  end

	# pandoc needs a complete dir of the network to work, otherwise it will not be able
	# to find the file. File paths which containt spaces make trouble, therefore we need
	# to wrap them around quotation marks.
	# Embedded media, like images, will be stored in the public/tmp/media/
  def	get_html_contents
		if is_word_file?
			`pandoc --extract-media public/tmp \"#{get_path}\" --from docx --to html`
		else
			"<p> could not parse document"
		end
	end

	def file_age(name)
		(Time.now - File.ctime(name))/(24*3600)
	end

	def	get_pdf_path
		puts "asking pdf file. copying #{mail.get_sources_directory}/#{name} to  app/public/tmp/mail"
		Dir.glob("app/public/tmp/mail/*.pdf").each { |filename| File.delete(filename) if file_age(filename) > 0 }
		if is_pdf_file?
			original_file = "#{mail.get_sources_directory}/#{name}"
			FileUtils.cp(original_file, "app/public/tmp/mail/#{name}")
			"/tmp/mail/#{name}"
		end
	end

	def is_word_file?
		[".docx", ".doc"].include? extension
	end

  def is_pdf_file?
		[".pdf"].include? extension
	end

end	#class end
