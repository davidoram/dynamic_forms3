# sample4.rb
require 'rubygems'
require 'sinatra'
require 'pathname'
require 'pp'
require_relative 'models/document'
require_relative 'models/schema'
require_relative 'models/user'
require_relative 'builder'
require_relative 'urlparser'

# For building html
builder = Builder.new

configure do
  # Allow _method=DELETE magic to allow PUT or DELETE in forms
  # Put a hidden field callled _method with value DELETE or PUT
  enable :method_override
  
  # Sessions store user credentials
  enable :sessions
  
  # Serve static files from /public
  set :public_folder, File.dirname(__FILE__) + '/public'
end

#----------------------------------------------------------------
#
# Helper functions
#
helpers do
end


#----------------------------------------------------------------
#
# Filter functions
#
before do
  pp "before filter: #{request.path_info}"
  
  # Skip authentication redirect if we are doing authentication
  pass if ['/session', '/session/new'].include? request.path_info
  
  if ! session.has_key? :user
    redirect '/session/new' 
  end
end

#----------------------------------------------------------------
#
# Miscellanious URLS
#


get '/' do
  redirect '/documents'
end

#----------------------------------------------------------------
#
# Session related URLS
#
# GET /session/new  - Presents a login form
# POST /session     - Authenticate & create a session
# DELETE /session   - Logout & redirect to login form

get '/session/new' do
  pp "new session"
  Builder.render_file 'login'
end

post '/session' do
  user = User.authenticate(params[:username], params[:password])
  if user
    pp "User in session: #{user.username} with roles #{user.roles}"
    session[:user] = user
    redirect '/documents'  
  else
    pp "Failed login for username: #{params[:username]}"
    Builder.render_file 'login', {:errors => ['invalid username & password']}
  end
end


# ------------------------------
#
# Document related URLs
#

get '/documents' do
  Builder.render_file 'documents', { 
      :documents => Document.find(:all),
      :schemas   => Schema.find(:all)
    }
end

# Form to add
post '/documents/add' do
  pp "Add a new document"
  schema = Schema.find(params[:df_schema])
  path = []
  pp "Using schema #{schema.id}"
  if schema.forms.count() == 0
    Builder.render_file 'documents', { 
        :documents => Document.find(:all),
        :schemas   => Schema.find(:all),
        :errors    => ["Schema has no associated form(s)"]
      }
  else
    form = schema.forms[0]  # Take the 1st one as default - should get the appropriate form for the users role
    document = Document.new()
    document.df_data = {}
    document.schema = schema
    if document.save
      redirect to("/documents/#{document.id}")
    else
      Builder.render_file 'documents', { 
          :documents => Document.find(:all),
          :schemas   => Schema.find(:all),
          :errors    => document.errors.values
      }
    end
  end
end

# Retrieve a  document for editing
# :id - documents df_id
# :path - URL encoding of the path to navgate within the data document to provide the correct
#         data context eg: '/employees/0'
# :section - identifier of the section to render with
get %r{/documents(/.*)} do
  pp "request.path: #{request.path}"
  url_parsed = UrlParser.parseUrl(request.path)
  pp url_parsed
  document = Document.find(url_parsed[:id])
  schema = document.schema
  form = schema.form_for session[:user]
  Builder.render_document(document, schema, form, url_parsed)
end

# Update a document
post %r{/documents(/.*)} do
  pp "post document"
  url_parsed = UrlParser.parseUrl(request.path)
  document = Document.find(url_parsed[:id])
  schema = document.schema
  form = schema.form_for session[:user]
  document.update_values(schema, form, url_parsed, @params[:form])
  document.save!
  'Saved ok'
end

# Delete
delete '/documents/:id' do
  Document.delete(params[:id])
  redirect to('/documents')
end


