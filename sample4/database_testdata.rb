require 'rubygems'
require 'active_record'
require 'pp'

require_relative 'schema'

schema_file = IO.readlines(File.dirname(__FILE__) + '/bin/schema.json').join('')
schema = Schema.new({:df_fields => JSON.parse(schema_file) })
schema.save!
pp "-- Added schema #{schema.id}"

form_file = IO.readlines(File.dirname(__FILE__) + '/bin/form.json').join('')
form = Form.new({:df_sections => JSON.parse(form_file) })
form.can_use_for(schema)
form.save!
pp "-- Added form #{form.id} associated with schema #{schema.id}"

