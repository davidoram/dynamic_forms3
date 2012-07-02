require 'rack'
require 'pp'
require 'df3/router'

module DF3

  class RackApp

    def initialize(app)
      @app = app
      @router = DF3::Router.new([
              { :route_regex => '/projects', :type => :collection },
              { :route_regex => '/?', :type => :static },
            ])
    end
    
    def call(env)
      request = Rack::Request.new(env)
      pp request
      response = @router.service(env)
      if response.nil?
        @app.call(env)
      else
        response
      end
    end

  end
  
end