require 'pp'
require_relative 'string'

module DF3
  
  # Parse a URL into its constituent parts
  class URL
  
    # Parse the Document URL path, so we turn from '/documents/16/employees/5/children'
    # to a list of elements each having a type of :array or :array_element
    def initialize(url)
      @url = url
      @path = parse_path
    end
    
    # Return a path element
    def [](index)
      @path[index]
    end
    
    def size
      @path.size
    end
    
    def each_part
      @path.each do |path_element|
        yield path_element
      end
    end
    
    
    private
    def parse_path
      elements = []
      path = @url.split('/')
      path.delete_if {|x| x == "" } 
      
      idx = 0
      while idx < path.length 
        element = {} 
        element[:type] = :array
        raise "Error at #{path[idx]}, expected a path identifier not a number" if path[idx].is_integer? 
        element[:name] = path[idx]
        idx = idx + 1
        if idx < path.length
          raise "Error at #{path[idx]}, expected a path index not an identifier" unless path[idx].is_integer? 
          element[:index] = Integer(path[idx])
          element[:type] = :array_element
          idx = idx + 1
        end
        elements << element
      end
      elements
    end
    
  end
  
end
    
    
