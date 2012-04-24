require 'rubygems'
require 'active_record'

DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
this_dir = File.dirname(__FILE__)
config = YAML.load_file("#{this_dir}/config/database.yml")[DATABASE_ENV]

ActiveRecord::Base.establish_connection(config)

ActiveRecord::Schema.define do  
  create_table :schemas do |table|
    table.column :df_fields, :text
  end

  create_table :forms do |table|
     table.column :df_section, :text
  end

  # Relationship table
  create_table :forms_schemas, :id => false do |table|
    table.column :form_id, :integer
    table.column :schema_id, :integer
  end
  
  create_table :documents do |table|
    table.column :schema_id, :integer
     table.column :df_data, :text
  end

end