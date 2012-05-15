class String  
  def is_integer?    
    true if Integer(self) rescue false  
  end 
  
  def is_json?
    true if JSON.parse(self) rescue false
  end
  
  def to_json
    JSON.parse(self)
  end
  
end


#---------------------------------------------------
#
# Class to parse URLs
#
class UrlParser
  
  # Types
  PRIMITIVE = 1
  ARRAY_ELEMENT = 2

  # Parse the Document URL path, so we turn from 16/employees/5/children
  # into:
  # { 
  #   :id => 16,
  #   :path => [ 
  #     {
  #       :name => 'employees', 
  #       :index => 5,
  #       :type => UrlParser::ARRAY_ELEMENT,
  #     },
  #     {
  #       :name => 'children', 
  #       :type => UrlParser::PRIMITIVE
  #     },
  #   :section_path = ['employees', '$employee_index', 'children']
  #   ],
  #   :url => '16/employees/5/children'
  # } 
  def UrlParser.parseDocumentUrl(url)
    path = url[0].split('/').compact.slice(1..-1)
    raise "Error at #{path[idx]}, document id not an identifier" unless path[0].is_integer? 
    idx = 1
    parray = []
    sparray = []
    
    while idx < path.length
      element = {} 
      element[:type] = UrlParser::PRIMITIVE
      raise "Error at #{path[idx]}, expected a path identifier not a number" if path[idx].is_integer? 
      element[:name] = path[idx]
      idx = idx + 1
      if idx < path.length
        raise "Error at #{path[idx]}, expected a path index not an identifier" unless path[idx].is_integer? 
        element[:index] = Integer(path[idx])
        element[:type] = UrlParser::ARRAY_ELEMENT
        idx = idx + 1
      end
      parray << element
      sparray << element[:name]
      sparray << "$#{element[:name]}" if element.has_key?(:index)
    end
    return {
      :id   => Integer(path[0]),
      :path => parray,
      :section_path => sparray,
      :url  => url[0]
    }
  end
  
end