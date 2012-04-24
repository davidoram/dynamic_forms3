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
  forms = Form.find(:all)
  render 'forms', { 
      :forms => forms  
    }
end

# Add or update
post '/forms' do
  #if is_valid_json? @params['df_sections']
  begin
    id = db.create_or_update( {
        'df_id' => @params['df_id'],
        'df_type' => @params['df_type'],
        'df_schema_id' => @params['df_schema_id'],
        'df_sections' => JSON.parse(@params['df_sections'])
    })
    redirect to('/forms')
  rescue RecordInvalid => error
    render 'form', {
        :df_id => @params['df_id'], 
        :df_type => @params['df_type'], 
        :df_schema_id => @params['df_schema_id'],
        :df_sections => @params['df_sections'],
        :errors => ["Invalid JSON"]  
      }
  end
end

# Form to add new
get '/forms/add' do
  render 'form', { 
      :df_id => '', 
      :df_type => 'form',
      :df_sections => nil  
    }
end

# View existng
get '/forms/:id' do
  doc = Form.find(params[:id])
  render 'form', { 
      :df_id => doc['df_id'], 
      :df_type => doc['df_type'], 
      :df_schema_id => doc['df_schema_id'],
      :df_sections => JSON.pretty_generate(doc['df_sections'])
    }
end

# Delete 
delete '/forms/:id' do
  Form.delete(params[:id])
  redirect to('/forms')
end



