# sample4.rb
require 'rubygems'
require 'sinatra'
require 'mustache'
require 'pathname'
require 'pp'
require_relative 'testdatabase'

this_dir = Pathname.new(File.dirname(__FILE__))
db = TestDatabase.new('/tmp/sample4_data')

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
  
  def is_valid_json?(document)
    begin
      JSON.parse(document)
      true
    rescue JSON::ParserError => ex
      pp ex
      false
    end
  end
end

#----------------------------------------------------------------
#
# Miscellanious URLS
#


get '/' do
  render 'index', { :name => 'bob' }
end

#----------------------------------------------------------------
#
# Schema related URLS
#


# Retrive list 
get '/schemas' do
  keys = db.list 'schema' #get_list_of('schema')
  pp keys
  render 'schemas', { 
      :schemas => keys  
    }
end

# Add or update 
# TODO - Should get df_id from URL for update
post '/schemas' do
  if is_valid_json? @params['df_fields']
    id = db.create_or_update( {
        'df_id' => @params['df_id'],
        'df_type' => @params['df_type'],
        'df_fields' => JSON.parse(@params['df_fields'])
    })
    redirect to('/schemas')
  else
    render 'schema', {
        :df_id => @params['df_id'], 
        :df_type => @params['df_type'], 
        :df_fields => @params['df_fields'],
        :errors => ["Invalid JSON"]  
      }
  end
end

# Form to add
get '/schemas/add' do
  render 'schema', { 
      :df_id => '', 
      :df_type => 'schema',
      :df_fields => nil 
    }
end

# View 
get '/schemas/:id' do
  doc = db.get(params[:id])
  render 'schema', { 
      :df_id => doc['df_id'], 
      :df_type => doc['df_type'], 
      :df_fields => JSON.pretty_generate(doc['df_fields'])
    }
end

# Delete
delete '/schemas/:id' do
  db.delete(params[:id])
  redirect to('/schemas')
end

#----------------------------------------------------------------
#
# Form related URLS
#

# Retrive list 
get '/forms' do
  keys = db.list 'form'
  pp keys
  render 'forms', { 
      :forms => keys  
    }
end

# Add or update
post '/forms' do
  if is_valid_json? @params['df_sections']
    id = db.create_or_update( {
        'df_id' => @params['df_id'],
        'df_type' => @params['df_type'],
        'df_sections' => JSON.parse(@params['df_sections'])
    })
    redirect to('/forms')
  else
    render 'form', {
        :df_id => @params['df_id'], 
        :df_type => @params['df_type'], 
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
  doc = db.get(params[:id])
  render 'form', { 
      :df_id => doc['df_id'], 
      :df_type => doc['df_type'], 
      :df_sections => JSON.pretty_generate(doc['df_sections'])
    }
end

# Delete 
delete '/forms/:id' do
  db.delete(params[:id])
  redirect to('/forms')
end



# ------------------------------


get '/documents' do
  'TODO - get documents'
end