require 'whenever'
require 'pandoc-ruby'

###########################################################################################
# DESCRIPTION
# A class defininign a file belonging to a mail. These are transient object in the DB.
# deleted once a day.
###########################################################################################

class MailFile < ActiveRecord::Base

	# the objet belongs to a mail object. Each mailfile can have only one mail file of a given name
	belongs_to  :mail
	validates 	:name, uniqueness: { scope: :mail_id }

  # Base dir for pandoc to find the sources when transforming docx document to html
	PANDOC_BASE_DIR = "//rafiki.cavabianca.org/datos/usuarios/abs/docs/GitHub/rpulpo/app/public/tmp/mail"
	NEW_PANDOC_BASE_DIR = "//rafiki.cavabianca.org/datos/usuarios/sect/"
	MAIL_FILES_DIR= "app/public/tmp/mail"

  enum file_type: {nota: 0, reference: 1, answer: 2}

   # creates a MailFile object given a file and a mail object.
	def self.create_from_file(file, mail)

		extension = File.extname(File.basename(file))
		mf = MailFile.create(mail: mail, name: file, extension: extension)

		# make sure the file is available in the tmp directory
		FileUtils.cp mf.get_original_path, mf.get_path
    return mf
	end

  def get_original_path
    return "#{mail.get_sources_directory}/#{name}"
  end

	def get_path
    return "#{MAIL_FILES_DIR}/#{id}#{extension}"
  end


	# pandoc needs a complete dir of the network to work, otherwise it will not be able
	# to find the file
  def	get_html_contents
		return ""  unless is_word_file?
		PandocRuby.new(["\"#{get_original_path}\""], from: 'docx').to_html
	end

	def is_word_file?
		[".docx", ".doc"].include? extension
	end

  def is_pdf_file?
		[".pdf"].include? extension
	end

end	#class end
