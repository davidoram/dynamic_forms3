require 'rack'
require 'pp'
require 'df3/router'

module DF3

  class RackApp
    
    DEBUG = false

    def initialize(app)
      @app = app
      @router = DF3::Router.new([ 
        { 
          :route_regex => '/jobs/submit', 
          :type => :controller 
        }, 
        { 
          :route_regex => '/projects/(\d+)/?', 
          :type => :document 
        }, 
        { 
          :route_regex => '/projects', 
          :type => :collection 
        }, 
        { 
          :route_regex => '/users/(\d+)/following', 
          :type => :store 
        }, 
        { 
          :route_regex => '/users/(\d+)/?', 
          :type => :document 
        }, 
        { 
          :route_regex => '/users', 
          :type => :collection 
        }, 
        { 
          :route_regex => '/?', 
          :type => :static 
        }])
    end
    
    def call(env)
      request = Rack::Request.new(env)
      pp request if DEBUG
      response = @router.service(env)
      if response.nil?
        @app.call(env)
      else
        response
      end
    end

  end
  
end