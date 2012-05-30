require 'rubygems'
require 'active_record'
require_relative 'models/database_configuration'

ActiveRecord::Schema.define do  
  create_table :schemas do |table|
    table.column :df_fields, :text
  end

  create_table :documents do |table|
    table.column :schema_id, :integer
    table.column :df_data, :text
  end

  create_table :users do |table|
    table.column :username, :string
    table.column :password, :string
    table.column :roles, :text
  end

end