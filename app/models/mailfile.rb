require 'whenever'
require 'pandoc-ruby'

###########################################################################################
# DESCRIPTION
# A class defininign a file belonging to a mail. These are transient object in the DB.
# deleted once a day.
###########################################################################################

class MailFile < ActiveRecord::Base

	# the objet belongs to a mail object. Each mail can have only one mail file of a given name
    belongs_to  :mail
    validates 	:name, uniqueness: { scope: :mail_id }

    # Base dir for pandoc to find the sources when transforming docx document to html
	PANDOC_BASE_DIR = "//rafiki.cavabianca.org/datos/usuarios/abs/docs/GitHub/rpulpo/app/public/tmp/mail"
	MAIL_FILES_DIR= "app/public/tmp/mail"

    enum file_type: {nota: 0, reference: 1, answer: 2}

    # creates a MailFile object given a file and a mail object.
	def self.create_from_file(file, mail)

		extension = File.extname(File.basename(file))
		mf = MailFile.create(mail: mail, name: file, extension: extension)

        #make sure the file is available in the mail directory
        src_file_path = "#{mf.mail.get_sources_directory}/#{mf.name}"

		# make sure the file is available in the tmp directory
		FileUtils.cp src_file_path, mf.get_path
    return mf
	end

    def get_original_path
        return "#{self.mail.get_sources_directory}/#{self.name}"
    end

	def get_path
        return "#{MAIL_FILES_DIR}/#{id}#{extension}"
    end

	def get_tmp_path
        "/tmp/mail/#{self.id}#{self.extension}"
    end

	# pandoc needs a complete dir of the network to work, otherwise it will not be able
	# to find the file
  def	get_html_contents
		is_word_file? ? (PandocRuby.new(["#{PANDOC_BASE_DIR}/#{self.id}#{self.extension}"], from: 'docx').to_html) : ""
	end

	def is_word_file?
		[".docx", ".doc"].include? extension
	end

    def is_pdf_file?
		[".pdf"].include? extension
	end
end	#class end

# deletes all the mailfiles and also the files stored in the tmp dir.
def clean_mailfiles
	MailFile.all.delete_all
	FileUtils.rm_rf Dir.glob("#{MAIL_FILES_DIR}/*") if dir.present?
end

stime = Time.now
midnight = Time.new(stime.year,stime.month,stime.day,24)

Thread.new do
	stime = Time.now
	midnight = Time.new(stime.year,stime.month,stime.day,24)
	sleep_time = midnight - stime
	while(true) do
		puts Rainbow("PULPO CLEANUP: next scheduled cleanup at #{midnight}").yellow
		sleep (sleep_time).day
		puts Rainbow("PULPO CLEANUP: cleaning tmpdir app/public/tmp/mail").yellow
		clean_mailfiles
		sleep_time = 3600*24 #sleep 24.hours
	end
end
