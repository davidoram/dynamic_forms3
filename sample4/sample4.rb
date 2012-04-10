# sample4.rb
require 'rubygems'
require 'sinatra'
require 'mustache'

helpers do
  def render(template, context = {})
    Mustache.render_file("#{File.dirname($0)}/templates/#{template}", context)
  end
end

get '/' do
  render 'index', { :name => 'bob' }
end

get '/documents' do
  'TODO - get documents'
end