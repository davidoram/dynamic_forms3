require_relative 'database_configuration'

class Document < ActiveRecord::Base
  belongs_to :schema
  serialize :df_data

  # Return a pointer to the position in this document represented
  # by the URL
  def navigate_to(url_parsed)
    pp "navigate_to #{url_parsed[:url]}"
    data = df_data
    url_parsed[:path].each do |element|
      type = element[:type]
      name = element[:name]
      index = element[:index]
      
      raise "Invalid path element #{name}" unless data.has_key? name
      if type == UrlParser::PRIMITIVE
        data = data[name]
      else type == UrlParser::ARRAY_ELEMENT
        raise "Invalid path element #{name} not an Array" unless data[name].is_a? Array
        if index < 0 || index >= data[name].length
          raise "Invalid array index #{name}[#{index}] - must be between 0 and #{data[name].length - 1}" 
        end
        data = data[name][index]
      end
    end
    data
  end
  
  def update_values(schema, section, url_parsed, values)
    # Navigate to the correct part of this document
    data = navigate_to(url_parsed)
    values.each do |key, value|
      data[key] = value
    end
  end

end