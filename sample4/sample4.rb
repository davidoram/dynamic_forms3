# sample4.rb
require 'rubygems'
require 'sinatra'
require 'mustache'
require 'pathname'
require 'pp'
require_relative 'schema'
require_relative 'builder'
require_relative 'urlparser'

# For building html
builder = Builder.new

configure do
  # Allow _method=DELETE magic to allow PUT or DELETE in forms
  # Put a hidden field callled _method with value DELETE or PUT
  enable :method_override
  
  # Serve static files from /public
  set :public_folder, File.dirname(__FILE__) + '/public'
end

helpers do
  def render(template, context = {})
    this_dir = Pathname.new(File.dirname(__FILE__))
    m = Mustache.new
    m.template_file = "#{this_dir}/templates/#{template}.mustache"
    m.render(context)
  end
  
end

#----------------------------------------------------------------
#
# Miscellanious URLS
#


get '/' do
  render 'index', { :name => 'bob' }
end

# ------------------------------
#
# Document related URLs
#

get '/documents' do
  render 'documents', { 
      :documents => Document.find(:all),
      :schemas   => Schema.find(:all)
    }
end

# Form to add
post '/documents/add' do
  pp "Add a new document"
  schema = Schema.find(params[:df_schema])
  path = []
  if schema.forms.count() == 0
    render 'documents', { 
        :documents => Document.find(:all),
        :schemas   => Schema.find(:all),
        :errors    => ["Schema has no associated form(s)"]
      }
  else
    form = schema.forms[0]  # Take the 1st one as default - should get the appropriate form for the users role
    document = Document.new()
    document.df_data = "{}"
    document.schema = schema
    if document.save
      redirect to("/documents/#{document.id}")
    else
      render 'documents', { 
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
  urlParams = UrlParser.parseDocumentUrl(params[:captures])
  pp urlParams
  document = Document.find(urlParams[:id])
  schema = document.schema
  if !schema.has_default_form?
    "Missing default form for that Schema"
  else
    form = schema.default_form
    Builder.render(document, schema, form, urlParams[:path])
  end
end

# Update a document
post '/documents/:id/path/:path/section/:section' do
  'TODO - update doc'
end


#----------------------------------------------------------------
#
# Schema related URLS
#


# Retrive list 
get '/schemas' do
  keys = Schema.find(:all)
  render 'schemas', { 
      :schemas => keys  
    }
end

# Add
post '/schemas/' do
  schema = Schema.new({
      :df_fields => @params['df_fields'] })
  if schema.save
    redirect to('/schemas')
  else
    render 'edit_schema', {
      :df_fields => @params['df_fields'],
      :errors    => schema.errors.values
    }
  end
end

# Update
post '/schemas/:id' do
  schema = Schema.find(params[:id])
  schema.df_fields = @params['df_fields']
  if schema.save
    redirect to('/schemas')
  else
    render 'edit_schema', {
      :id        => params[:id], 
      :df_fields => @params['df_fields'],
      :errors    => schema.errors.values
    }
  end
end


# Form to add
get '/schemas/add' do
  render 'edit_schema', { }
end

# View 
get '/schemas/:id' do
  pp "Get schema #{params[:id]}"
  doc = Schema.find(params[:id])
  pp doc
  render 'edit_schema', doc.attributes
end

# Delete
delete '/schemas/:id' do
  Schema.delete(params[:id])
  redirect to('/schemas')
end

#----------------------------------------------------------------
#
# Form related URLS
#

# Retrive list 
get '/forms' do
  keys = Form.find(:all)
  pp keys
  render 'forms', { 
      :forms => keys  
    }
end

# Add
post '/forms/' do
  form = Form.new({
      :df_sections => @params['df_sections'] })
  if form.save
    redirect to('/forms')
  else
    render 'edit_form', {
      :df_sections => @params['df_sections'],
      :schemas     => @params['schemas'],
      :errors      => form.errors.values
    }
  end
end

# Update
post '/forms/:id' do
  form = Form.find(params[:id])
  form.df_sections = @params['df_sections']
  pp @params
  form.schemas = []
  @params['associated_with_schemas'] = {} unless @params.has_key? 'associated_with_schemas'
  new_schema_ids = @params['associated_with_schemas'].keys
  new_schema_ids.each do |schema_id|
    form.can_use_for(Schema.find(schema_id))
  end
  
  if form.save
    redirect to('/forms')
  else
    render 'edit_form', {
      :id          => params[:id], 
      :df_sections => @params['df_sections'],
      :schemas     => @params['schemas'],
      :errors      => form.errors.values
    }
  end
end


# Form to add
get '/forms/add' do
  render 'edit_form', { }
end

# View 
get '/forms/:id' do
  pp "Get form #{params[:id]}"
  doc = Form.find(params[:id])
  all_schemas = Schema.find(:all)
  associated_with_schemas = []
  all_schemas.each do |schema|
    associated_with_schemas << { 
      :schema_id     => schema.id,
      :is_associated => !doc.schemas.index(schema).nil?
    }
  end
  pp associated_with_schemas
  render 'edit_form', doc.attributes.merge( { :all_schemas => all_schemas, :associated_with_schemas => associated_with_schemas })
end

# Delete
delete '/forms/:id' do
  Form.delete(params[:id])
  redirect to('/forms')
end



