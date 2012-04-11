# sample4.rb
require 'rubygems'
require 'sinatra'
require 'mustache'
require 'pathname'
this_dir = Pathname.new(File.dirname(__FILE__))

helpers do
  def render(template, context = {})
    this_dir = Pathname.new(File.dirname(__FILE__))
    m = Mustache.new
    m.template_file = "#{this_dir}/templates/#{template}.mustache"
    m.render(context)
  end
end

get '/' do
  render 'index', { :name => 'bob' }
end

get '/documents' do
  'TODO - get documents'
end