
# docx_writer.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# autor: alejandrobertelsen@gmail.com
# last major update: 2024-11-24
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION

# A class to produce docx files.

#require 'caracal'
require 'pandoc-ruby'

class WordWriter  < DocumentWriter

	DEFAULT_SIGNATURES_NUM = 6
	DEFAULT_SIGNATURES = ["sect", "vr", "r"]
	DEFAULT_TMP_DIR = "app/public/tmp/mail"
	PANDOC_REFERENCE = "app/engines-templates/word/custom.docx"

	attr_accessor :path

	# the constructor receive
	# @mail: a mail objet that serves as the base for the document.
	def initialize(mail, user)
		@mail = mail
		@user = user
		@dir = "#{Mail::BALDAS_BASE_DIR}/#{@user.uname}"
		@path = "app/public/tmp/mail/draft-#{mail.id}.docx"

		#@doc = Caracal::Document.new @path
	end

		# delete all files int the TYPST_TEMPLATES_DIR with suffixes .tmp.typ and .tmp.pdf
		def clean_tmp_files
			files = Dir.glob("#{DEFAULT_TMP_DIR}/*.docx")
			#puts "DELETING FILES #{files}"
			files.each { |file| File.delete file }
		end

	def write_document()
		md_src = get_header_table << get_topic << get_references << get_draft
		file = PandocRuby.markdown(md_src, :standalone, "--reference-doc \"#{PANDOC_REFERENCE}\" --preserve-tabs").to_docx
		File.binwrite(@path, file)
		return self
	end

	def get_signatures()
		(["#{@user.uname}"] + (DEFAULT_SIGNATURES - [@user.uname])) + ["",""]
	end

	def get_plain_text(text)
		#puts text
		#ext.gsub!("\n\n","*****").gsub!("\n"," ").gsub!("*****","\n")
		text
	end

	def get_header_table()
		signatures = get_signatures
		#signatures = (signatures.inject("|"){|res,elem| res << " ```#{elem}``` |" }) << "\n" << (signatures.inject("|"){|res,elem| res << "-|" }) << "\n\n"
		signatures = "\n```\nFIRMAS:\t" << (signatures.inject(""){|res,elem| res << " #{elem} \t\t" }) << "\n````\n\n"
	end

	def get_references()
		references = "\n\n## ANTECEDENTES:"
		@mail.refs.each do |ref|
			references << "\n\n### #{ref.protocol}" << "\n\n"
			ref.find_related_files.each do |mf|
				references << get_reference(mf)
			end
		end
		references
	end

	def get_reference(mf)
		if mf.is_word_file?
			#@doc.p mf.name, style: 'reference_name'
			get_plain_text mf.get_md_contents
		else
			"\n\n### [#{mf.name}](#{mf.get_path})"
		end
	end

	def get_topic()
		"\n\n# ASUNTO: #{@mail.topic}"
	end

	def get_draft()
		"\n\n<br>\n\n## PROPUESTA:\n\n" << "#### #{@mail.protocol}\n\n" << "\n\n1. Nos parece" << "\n\n#### Roma, #{Time.now.strftime("%d-%m-%y")}"
	end

end #class end
