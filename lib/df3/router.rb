require 'pp'
require_relative 'url_parser'
require_relative 'database'

module DF3
  
  # Parse a URL into its constituent parts
  class Router
    
    DEBUG = true
    
    # Errors
    METHOD_NOT_ALLOWED = [405, {'Content-Type' => 'text/html'}, ['Method not allowed in this context']]
    
    
    # Create a router that will service the routes specified
    #
    # @param [Hash] routes to service
    # {
    #   '/' => { :type => :static, :root=> 'public', :file => '/public/index.html' },
    #   '/projects' => { :type => :collection },
    #   '/users' => { :type => :collection }
    #   '/users/{user_id}/bookmarks' => { :type => :store }
    #   '/jobs/{job_id}/pause' => { :type => :controller }
    # }
    def initialize(routes)
      @routes = routes
      @db = DF3::Database.new
    end
    

    # service a request
    # 
    # @param [Hash] Rack environment
    def service(env)
      request = Rack::Request.new(env)
      url = DF3::URL.new(env['REQUEST_URI'], @routes)
      pp "----------\nService URL: #{url}" if DEBUG
      # Service depending on type
      case 
      when url.is_static?
        [200, {'Content-Type' => 'text/html'}, ['Static TODO - Integate Rack::Static']]
      when url.is_collection?
        service_collection(env, request, url)
      when url.is_document?
        [200, {'Content-Type' => 'text/html'}, ['Document TODO - ']]
      when url.is_store?
        [200, {'Content-Type' => 'text/html'}, ['Store  TODO - ']]
      when url.is_controller?
        [200, {'Content-Type' => 'text/html'}, ['Controller  TODO - ']]
      else
        pp 'Unhandled' if DEBUG
        nil
      end  
    end

  private

    # service a collection
    #
    # GET collection will return a list of values in the collection
    # respects the following query parameters:
    # pageSize={int} determines the number of results on the page, defaults to 10
    # pageStartIndex={int} determines the page of results to return, defaults to 0
    # {column}={value} will filter the collection to show data with column values that match that value
    #
    # POST adds a document to the collection
    #
    def service_collection(env, request, url)
      case 
      when request.get?
        pageSize = request['pageSize']
        pageSize = pageSize ||= 10
        pageStartIndex = request['pageStartIndex']
        pageStartIndex = pageStartIndex ||= 0
        data = @db.find_in_collection(url.collection, pageSize, pageStartIndex)
        [200, {'Content-Type' => 'text/html'}, ['Collection GET TODO', data.to_s]]
      when request.post?
        [200, {'Content-Type' => 'text/html'}, ['Collection POST TODO']]
      else
        METHOD_NOT_ALLOWED
      end
    end
    
  end
end