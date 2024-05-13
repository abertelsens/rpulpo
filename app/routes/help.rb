require 'kramdown'
require 'github/markup'

# adds or removes all the visible people on a table from the current set.
get '/help' do
  @current_user = get_current_user
  partial :help
end

get '/help/:page' do
  file_body = Kramdown::Document.new(File.read("app/views/help/#{params[:page]}.md")).to_html
  "<turbo-frame id=\"help_frame\" target=\"help_frame\">
  #{file_body}
  </turbo-frame>"
end