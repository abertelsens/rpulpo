# documents.rb
#---------------------------------------------------------------------------------------
# FILE INFO

# author: alejandrobertelsen@gmail.com
# last major update: 2024-10-05
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# DESCRIPTION
# ROUTES CONTROLLERS FOR THE documents TABLE
#---------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------

# renders the documents frame
get '/documents' do
  slim :"frame/simple_template",  locals: {title: "DOCUMENTS", model_name: "document"}
end

# renders the table of documents
# @objects - the documents that will be shown in the table
get '/documents/table' do
  @table_settings = TableSettings.get(:documents_default)
  @objects = get_current_user.documents
  @decorator = DocumentDecorator.new(table_settings: @table_settings)
  partial :"table/simple_template"
end

# renders a single document form
get '/document/:id' do
  @object = (params[:id]=="new" ? nil : Document.find(params[:id]))
  slim :"form/document"
end

# renders in the browser the template of a document
get '/document/:id/viewtemplate' do
  @document = (params[:id]=="new" ? nil : Document.find(params[:id]))
  src = File.read @document.get_full_path
	header = "<link rel=\"stylesheet\"
    href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css\">
    <script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js\">
    </script><script>hljs.highlightAll();</script>
    <style>.hljs { white-space: pre; overflow-x: auto;}</style>"
	header << "<h1>Source for template: #{@document.name}</h1>
  <div style=\"width: 90%\">
  <pre><code>#{src}</code></pre>
  </div>"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

post '/document/:id' do
	case params[:commit]
		when "new"		then	Document.create params
		when "save" 	then 	Document.find(params[:id]).update params
		when "delete" then 	Document.find(params[:id]).destroy
	end
	redirect '/documents'
end

# Validates if the params received are valid for updating or creating an entity object.
# returns a JSON object of the form {result: boolean, message: string}
post '/document/:id/validate' do
	content_type :json
  (new_id? ? (Document.validate params) : (Document.find(params[:id]).validate params)).to_json
end
