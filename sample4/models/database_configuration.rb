require 'rubygems'
require 'active_record'

DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
this_dir = File.dirname(__FILE__)
config = YAML.load_file("#{this_dir}/../config/database.yml")[DATABASE_ENV]

ActiveRecord::Base.establish_connection(config)
