# -----------------------------------------------------------------------------------------
# ROUTES CONTROLLERS FOR THE DOCUMENT OBJECT
# -----------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------
# GET ROUTES
# -----------------------------------------------------------------------------------------
# renders the documents frame
get '/documents' do
  @current_user = get_current_user
  partial :"frame/documents"
end

# renders the table of documents
# @objects - the documents that will be shown in the table
get '/documents/table' do
  @objects = Document.get_docs_of_user get_current_user
  partial :"table/documents"
end

# renders a single document form
get '/document/:id' do
  @object = (params[:id]=="new" ? nil : Document.find(params[:id]))
  partial :"form/document"
end

# renders in the browser the template of a document
get '/document/:id/viewtemplate' do
  @document = (params[:id]=="new" ? nil : Document.find(params[:id]))
  src = File.read @document.get_full_path
	header = "<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css\"><script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js\"></script><script>hljs.highlightAll();</script>"
	header << "<h1>Source for template: #{@document.name}</h1>
	<pre><code>#{src}</code></pre>"
end

# -----------------------------------------------------------------------------------------
# POST ROUTES
# -----------------------------------------------------------------------------------------

post '/document/:id' do
  @document = (params[:id]=="new" ? nil : Document.find(params[:id]))
  case params[:commit]
    when "save"
      if @document.nil?
        @document = Document.create_from_params params
      else
      	res = @document.update_from_params params
        check_update_result res
      end
    when "delete" then @document.destroy
  end
  redirect '/documents'
end
