require 'rubygems'
require 'active_record'
require 'pp'

require_relative 'models/schema'
require_relative 'models/user'

schema_file = IO.readlines(File.dirname(__FILE__) + '/bin/schema.json').join('')
schema = Schema.new({:df_fields => JSON.parse(schema_file) })
schema.save!
pp "-- Added schema #{schema.id}"

user = User.new({:username => 'bob', :password => 'password', :roles => ['user', 'reviewer']})
user.save!
pp "-- Added user #{user.username} #{user.id}"
user = User.new({:username => 'sue', :password => 'password', :roles => ['user']})
user.save!
pp "-- Added user #{user.username} #{user.id}"
