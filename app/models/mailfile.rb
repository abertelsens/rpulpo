# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-10-05

# DESCRIPTION
# A class defininig a file belonging to a mail. I refers to an actual document that can
# contain the text of the mail or some annexes

require 'pandoc-ruby'

class MailFile < ActiveRecord::Base

	# The object belongs to a mail object.
	# Each mail_file can have only one mail file of a given name
	belongs_to  :mail

	validates 	:name, uniqueness: { scope: :mail_id }

	TMP_DIR = "app/public/tmp/mail"
	PUBLIC_TMP_DIR = "/tmp/mail"

	# CRUD

  # Creates a MailFile object given a file and a mail object.
  # @param file [String] the file path
  # @param mail [Mail] the mail object
  # @return [MailFile] the created MailFile object
	def self.create_from_file(file, mail)
		extension 	= File.extname(File.basename(file))
		path 				= File.join mail.get_sources_directory, file
		mailfile		= MailFile.create(mail: mail, name: file, extension: extension, mod_time: File.mtime(path))
		mailfile.update_html
	end

  def get_path
    return nil if mail.nil? || name.nil?
  	File.join(mail.get_sources_directory, name)
  end

	def get_contents(format)
		return "<p>could not parse document</p>" unless is_word_file?
		html_string = case format
			when :html 					then `pandoc --email-obfuscation=none --extract-media tmp \"#{get_path}\" --from docx --to html`
			when :md, :markdown then `pandoc --email-obfuscation=none \"#{get_path}\" --from docx --to markdown`
			when :txt 					then `pandoc --email-obfuscation=none \"#{get_path}\" --from docx --to plain`
		end
		clean_html html_string
	end


	def clean_html(html_string)
		html_string.gsub(/<script.*?>(.+?)<\/script>/, '\1').gsub(/<noscript.*?>(.+?)<\/noscript>/, '\1')
	end

	# gets the pdf path of a mail_file. Used to preview an annexes.
	def	get_pdf_path
		# Delete all the files in the tmp folder that are older than one day
		Dir.glob("#{TMP_DIR}/*.pdf").each do |filename|
			File.delete(filename) if file_age(filename) > 1
		end
		original_file = "#{mail.get_sources_directory}/#{name}"
		FileUtils.cp(original_file, File.join(TMP_DIR, name))
		File.join PUBLIC_TMP_DIR, name
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
		update(html: get_contents(:html), mod_time: Time.now)	if (is_word_file? && (has_been_modified? || html==nil))
	end

	# checks whether the modification time of the file in the file system is later
	# than the version we have in the db. If we have no modification time in the db
	# we return true.
	def has_been_modified?
		if mod_time
			(File.mtime(get_path) > mod_time)
		else
			update(mod_time: File.mtime(get_path))
			true
		end
	end
end	#class end
