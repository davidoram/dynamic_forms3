# sample4.rb
require 'rubygems'
require 'sinatra'
require 'mustache'
require 'pathname'
require 'pp'
require_relative 'schema'
require_relative 'builder'

# For building html
builder = Builder.new

configure do
  # Allow _method=DELETE magic to allow PUT or DELETE in forms
  # Put a hidden field callled _method with value DELETE or PUT
  enable :method_override
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
  docs = Documents.find(:all)
  render 'documents', { 
      :documents => docs
    }
end

# Form to add
post '/documents/add' do
  schema = Schema.find(params[:df_schema])
  path = []
  section = Form.get_form_for_schema(params[:df_schema])
  document = {}
  builder.render(schema, section, path, document)
end

# Retrieve a  document for editing
# :id - documents df_id
# :path - URL encoding of the path to navgate within the data document to provide the correct
#         data context eg: '/employees/0'
# :section - identifier of the section to render with
get '/documents/:id/path/:path/section/:section' do
  'TODO - get data for section'
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
      :errors    => form.errors.values
    }
  end
end

# Update
post '/forms/:id' do
  form = Form.find(params[:id])
  form.df_sections = @params['df_sections']
  if form.save
    redirect to('/forms')
  else
    render 'edit_form', {
      :id        => params[:id], 
      :df_sections => @params['df_sections'],
      :errors    => form.errors.values
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
  pp doc
  render 'edit_form', doc.attributes
end

# Delete
delete '/forms/:id' do
  Form.delete(params[:id])
  redirect to('/forms')
end



