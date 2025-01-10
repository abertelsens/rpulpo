
# docx_writer.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-12-20
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class to produce docx files.

require 'pandoc-ruby'
require_relative '../utils/utils'

class WordWriter  < DocumentWriter

	include Utils

	DEFAULT_SIGNATURES_NUM 	= 6
	DEFAULT_SIGNATURES 			= ["sect", "vr", "r"]
	DEFAULT_TMP_DIR 				= "app/public/tmp/mail"
	PANDOC_REFERENCE 				= "app/engines-templates/word/custom.docx"

	attr_accessor :path

	# the constructor receive
	# @mail: a mail objet that serves as the base for the document.
	# @user: the user that is creating the draft.
	def initialize(mail, user)
		@mail = mail
		@user = user
		@dir 	= "#{Mail::BALDAS_BASE_DIR}/#{@user.uname}"
		@path = "#{DEFAULT_TMP_DIR}/draft-#{mail.id}.docx"
	end

		# delete all files int the TYPST_TEMPLATES_DIR with suffixes .tmp.typ and .tmp.pdf
		def clean_tmp_files
			files = Dir.glob("#{DEFAULT_TMP_DIR}/*.docx")
			files.each { |file| File.delete file }
		end

	def write_document()
		references = @mail.refs.nil? ? "" : get_references
		md_src = get_header_table << get_topic << references << get_draft
		file = PandocRuby.markdown(md_src, :standalone, "--reference-doc \"#{PANDOC_REFERENCE}\" --preserve-tabs").to_docx
		File.binwrite(@path, file)
		return self
	end

	def get_signatures()
		(["#{@user.uname}"] + (DEFAULT_SIGNATURES - [@user.uname])) + ["",""]
	end

	def get_header_table()
		"\n```\nFIRMAS:\t" << (get_signatures.inject(""){|res,elem| res << "#{elem}\t\t" }) << "\n````\n\n"
	end

	def get_references()
		references = "\n\n## ANTECEDENTES:"
		@mail.refs.each do |ref|
			references << "\n\n### #{ref.protocol}" << "\n\n"
			ref.find_related_files.each {|mf| (references << get_reference(mf)) }
		end
		references
	end

	def get_reference(mf)
		mf.is_word_file? ? mf.get_contents(:md) : "\n\n### [#{mf.name}](#{mf.get_path})"
	end

	def get_topic()
		"\n\n# ASUNTO: #{@mail.topic}"
	end

	def get_draft()
		roman_date = roman_month_date(Time.now.strftime("%d-%m-%Y"))
		res = "\n\n<br>\n\n## PROPUESTA:\n\n"
		res << "<div custom-style=\"protocol\">#{@mail.protocol}</div>\n\n"
		res << "<br>1. Nos parece....\n\n"
		res << "<div custom-style=\"align-right\">Roma, #{roman_date}</div>"
	end

end #class end
