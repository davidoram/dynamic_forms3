require 'pp'
require_relative 'url_parser'

module DF3
  
  # Parse a URL into its constituent parts
  class Router
    
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
    end
    

    # service a request
    # 
    # @param [Hash] Rack environment
    def service(env)
      request = Rack::Request.new(env)
      url = DF3::URL.new(request.path_info, @routes)

      # Service depending on type
      case 
      when url.is_static?
        return [200, {'Content-Type' => 'text/html'}, ['Static TODO - Integate Rack::Static']]
      when url.is_collection?
        return [200, {'Content-Type' => 'text/html'}, ['Collection TODO - ']]
      when url.is_document?
        return [200, {'Content-Type' => 'text/html'}, ['Document TODO - ']]
      when url.is_store?
        return [200, {'Content-Type' => 'text/html'}, ['Store  TODO - ']]
      else
        pp 'Unhandled'
        return nil
      end  
      
    end

  end
end