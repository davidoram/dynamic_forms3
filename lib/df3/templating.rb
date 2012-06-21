require 'pp'

module DF3
  
  module Render
    
    DEBUG = false
      
    def Render.render(template, data, formatter)   
      formatter.on_object_start
      
      template['fields'].each do |field|
        pp "Field: #{field}" if DEBUG
        pp "Data: #{data[field['id']]}" if DEBUG
        # Get the data values for this field
        field_data = data[field['id']]
        
        # Process Array data type
        if field['type'] == 'array'
          formatter.on_array_start(field, field_data)
          
          # Process the array header - containing the metadata 
          formatter.on_array_header_start(field, field_data)
          field['fields'].each do |column|
            formatter.on_column(column, field_data)
          end
          formatter.on_array_header_end(field, field_data)
          
          field_data.each do |array_field|
            # Go recursive for the values in the array
            render(field, array_field, formatter)
          end
          formatter.on_array_end(field, field_data)
        else

          # Process primitive data type
          formatter.on_primitive(field, field_data)
        end
          
      end
      
      formatter.on_object_end
    end
  end
end