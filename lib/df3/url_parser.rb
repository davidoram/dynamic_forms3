require 'pp'
require_relative 'string'

module DF3
  
  # Parse a URL into its constituent parts
  class URL
  
    attr_reader :type
    
    # Parse the Document URL path, so we turn from '/documents/16/employees/5/children'
    # to a list of elements each having a type of :collection or :document
    # @param [Array] routes to service
    # [
    #   { :route_regex => '/', :type => :static },
    #   { :route_regex => '/projects', :type => :collection },
    #   { :route_regex => '/users', :type => :collection }
    #   { :route_regex => '/users/(\d+)/bookmarks', :type => :store }
    #   { :route_regex => '/jobs/(\d+)/pause', :type => :controller }
    # ]
    def initialize(url, routes)
      @url = url
      @routes = routes
      @type = parse_type
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
    
    # Returns true if the URL represents a collection
    # ie: '/documents' is a collection whereas '/documents/1' is a document
    def is_collection?
      return @type == :collection
    end
    
    # Returns true if the URL represents a static document
    # ie: '/' is a might be a static document
    def is_static?
      return @type == :static
    end
    
    # Returns true if the URL represents a store
    def is_store?
      return @type == :store
    end
    
    # Returns true if the URL represents a controller
    def is_controller?
      return @type == :controller
    end
    
    # Returns true if we cant find a match for the URL
    def is_umatched?
      return @type == :unknown
    end
    
    
  private

    def parse_type
      type = nil
      @routes.each do |value|
        if @url.match(value[:route_regex])
          type = value[:type]
          break
        end
      end
      if type.nil? 
        type = :unknown
      else
        raise "Illegal type #{@type}" unless [:static, :collection, :store, :controller].include? type
      end
      type
    end

    def parse_path
      elements = []
      path = @url.split('/')
      path.delete_if {|x| x == "" } 
      
      idx = 0
      while idx < path.length 
        element = {} 
        element[:type] = :collection
        raise "Error at #{path[idx]}, expected a path identifier not a number" if path[idx].is_integer? 
        element[:name] = path[idx]
        idx = idx + 1
        if idx < path.length
          raise "Error at #{path[idx]}, expected a path index not an identifier" unless path[idx].is_integer? 
          element[:index] = Integer(path[idx])
          element[:type] = :document
          idx = idx + 1
        end
        elements << element
      end
      elements
    end
    
  end
  
end
