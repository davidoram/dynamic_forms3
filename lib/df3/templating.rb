require 'pp'

module DF3
  
  module Render
    
    DEBUG = false

    # Navigate to the correct place in the data & render that data into a view
    #
    # @param [JSON] template defines the structure of the data being rendered, fields etc
    # @param [JSON] contains the data values to populate the fields with initially
    # @param [DF3::Formatter] is called upon to render the view, through events being raised on it
    # @param [DF3::URL] is used to determine the path to navigate to within the template & data
    def Render.navigate_and_render(template, data, formatter, url)
      template = navigate_template(template, url)
      data = navigate_data(data, url)
      render(template, data, formatter)
    end   


    # Navigate to the correct part of a template for rendering a URL
    #
    # @param [JSON] template defines the structure of the data being rendered, fields etc
    # @param [DF3::URL] is used to determine the path to navigate to within the template & data
    # @returns [JSON] template at the correct point that matches the URL
    def Render.navigate_template(template, url)
      url.each_part do |part|
        template['fields'].each do |field|
          if field['id'] == part[:name]
            template = field
            break
          end
        end
      end
      template
    end

    # Navigate to the correct part of a data for rendering a URL
    #
    # @param [JSON] data to be rendered
    # @param [DF3::URL] is used to determine the path to navigate to within the data
    # @returns [JSON] data at the correct point that matches the URL
    def Render.navigate_data(data, url)
      url.each_part do |part|
        if part[:type] == :collection
          data = data[part[:name]]
        elsif part[:type] == :document
          data = data[part[:name]][part[:index]]
        else
          raise "Error unknown type: #{part[:type]}"
        end
      end
      data
    end

    
    # Render data into a view
    #
    # @param [JSON] template defines the structure of the data being rendered, fields etc
    # @param [JSON] contains the data values to populate the fields with initially
    # @param [DF3::Formatter] is called upon to render the view, through events being raised on it
    def Render.render(template, data, formatter)   
      formatter.on_object_start(template, data)
      
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
          
          field_data.each_index do |index|
            
            # Add the special metadata key holding the index, indicating 
            # where the object is positioned in the array
            field_data[index]['df_index'] = index
            
            # Go recursive for the values in the array
            render(field, field_data[index], formatter)
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