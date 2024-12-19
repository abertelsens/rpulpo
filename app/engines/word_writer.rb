
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

class WordWriter  < DocumentWriter

	DEFAULT_SIGNATURES_NUM = 6
	DEFAULT_SIGNATURES = ["sect", "vr", "r"]
	DEFAULT_TMP_DIR = "app/public/tmp/mail"

	attr_accessor :path

	# the constructor receive
	# @mail: a mail objet that serves as the base for the document.
	def initialize(mail, user)
		@mail = mail
		@user = user
		@dir = "#{Mail::BALDAS_BASE_DIR}/#{@user.uname}"
		@path = "app/public/tmp/mail/draft-#{mail.id}.docx"
		@doc = Caracal::Document.new @path
	end

		# delete all files int the TYPST_TEMPLATES_DIR with suffixes .tmp.typ and .tmp.pdf
		def clean_tmp_files
			files = Dir.glob("#{DEFAULT_TMP_DIR}/*.docx")
			#puts "DELETING FILES #{files}"
			files.each { |file| File.delete file }
		end


	def write_document()

		clean_tmp_files
		define_styles
		write_header_table
		write_topic
		write_references
		write_draft
		@doc.save
		return self
	end

	def define_styles()
		@doc.style id: 'Normal', name: 'normal', font: "Arial"
		@doc.style id: 'ref_text', name: 'ref_text', size: 18, bold: false, bottom: 120, top:0, indent_left: 720, line: 280
		@doc.style id: 'antecedentes', name: 'antecedentes', size: 20, bold: true, bottom: 90,  top: 180
		@doc.style id: 'reference', name: 'reference', size: 20, bold: true, indent_left: 0
		@doc.style id: 'reference_name', name: 'reference_name', size: 20, bold: true, indent_left: 0
		@doc.style id: 'asunto', name: 'asunto', size: 24, bold: true, bottom: 120, top: 240
		@doc.style id: 'propuesta', name: 'propuesta', size: 20, bold: true, indent_left: 0, bottom: 90, top:180
	end

	def get_signatures()
		(["#{@user.uname} #{Time.now.strftime("%d-%m-%y")}"] + (DEFAULT_SIGNATURES - [@user.uname])) + ["\n","\n",""]
	end

	def write_plain_text(text)
		#puts text
		text.gsub!("\n\n","*****").gsub!("\n"," ").gsub!("*****","\n")
		text.split("\n").each { |p| @doc.p p, style: 'ref_text' }
	end

	def write_header_table()
		@doc.table [get_signatures] do
			cell_style rows[0], bold: true, size: 16
			border_color   	'666666'   # sets the border color. defaults to 'auto'.
			border_line    	:single    # sets the border style. defaults to :single. see OOXML docs for details.
			border_size    	1          # sets the border width. defaults to 0. units in twips.
		end
	end

	def write_references()
		@doc.p "ANTECEDENTES:", style: 'antecedentes'
		@mail.refs.each do |ref|
			ref.find_related_files.each { |elem| write_reference elem }
		end
	end

	def write_reference(mf)

		if mf.is_word_file?
			@doc.p mf.name, style: 'reference_name'
			write_plain_text mf.get_text_contents
		else
			@doc.p do
				link mf.name, mf.get_path, style: 'reference_name'
			end
		end
	end

	def write_topic()
		@doc.p "ASUNTO: #{@mail.topic}", style: 'asunto'
	end

	def write_draft()
		@doc.p "PROPUESTA:", style: 'propuesta'

		@doc.p "*            *            *" do
			align :center
		end

		@doc.p ""

		@doc.p @mail.protocol do
			align :right
		end

		@doc.p ""

		@doc.list_style do
			type    :ordered    # sets the type of list. accepts :ordered or :unordered.
			level   2           # sets the nesting level. 0-based index.
			format  'decimal'   # sets the list style. see OOXML docs for details.
			value   '%3.'       # sets the value of the list item marker. see OOXML docs for details.
			align   :left       # sets the alignment. accepts :left, :center: and :right. defaults to :left.
			indent  400         # sets the indention of the marker from the margin. units in twips.
			left    800         # sets the indention of the text from the margin. units in twips.
			start   1           # sets the number at which item counts begin. defaults to 1.
			restart 1           # sets the level that triggers a reset of numbers at this level. 1-based index. 0 means numbers never reset. defaults to 1.
		end

		@doc.ol do
			li 'Nos parece...'
		end

	end

end #class end
