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


# Retrive list of schemas
get '/schemas' do
  keys = db.list 'schema' #get_list_of('schema')
  pp keys
  render 'schemas', { 
      :schemas => keys  
    }
end

# Add or update a schema
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

# Retrieve the form required to add a schema
get '/schemas/add' do
  render 'schema', { 
      :df_id => '', 
      :df_type => 'schema',
      :df_fields => {}  
    }
end

# View an existng schema
get '/schemas/:id' do
  doc = db.get(params[:id])
  render 'schema', { 
      :df_id => doc['df_id'], 
      :df_type => doc['df_type'], 
      :df_fields => JSON.pretty_generate(doc['df_fields'])
    }
end

# Delete a schema
delete '/schemas/:id' do
  db.delete(params[:id])
  redirect to('/schemas')
end

#----------------------------------------------------------------
#
# Form related URLS
#


get '/forms' do
  'TODO - get documents'
end

get '/documents' do
  'TODO - get documents'
end