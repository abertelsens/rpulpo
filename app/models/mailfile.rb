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
	# Embedded media, like images, will be stored in the p
  def	get_html_contents
		return ""  unless is_word_file?
		`pandoc --extract-media public/tmp \"#{get_path}\" --from docx --to html`
	end

	def is_word_file?
		[".docx", ".doc"].include? extension
	end

  def is_pdf_file?
		[".pdf"].include? extension
	end

end	#class end
