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

  # Parse the Document URL path, so we turn from 16/employees/5/children
  # into:
  # { 
  #   :id => 16,
  #   :path => [ 
  #     {
  #       :name => 'employees', 
  #       :index => 5
  #     },
  #     {
  #       :name => 'children', 
  #     },
  #   ]
  # } 
  def UrlParser.parseDocumentUrl(url)
    path = url[0].split('/').compact.slice(1..-1)
    raise "Error at #{path[idx]}, document id not an identifier" unless path[0].is_integer? 
    idx = 1
    parray = []
    
    while idx < path.length
      element = {} 
      raise "Error at #{path[idx]}, expected a path identifier not a number" if path[idx].is_integer? 
      element[:name] = path[idx]
      idx = idx + 1
      if idx < path.length
        raise "Error at #{path[idx]}, expected a path index not an identifier" unless path[idx].is_integer? 
        element[:index] = Integer(path[idx])
        idx = idx + 1
      end
      parray << element
    end
    return {
      :id => Integer(path[0]),
      :path => parray
    }
  end
  
end