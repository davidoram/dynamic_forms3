# 
# Configure the Rack application
# 
require 'rack'
require 'rack/contrib'
require 'df3/rack_app'


# Allow HTML forms to override the HTTP verb
use Rack::MethodOverride

if ENV['RACK_ENV'] == 'development'
  # Display errors on screen when developing
  use Rack::ShowExceptions
else
  # Mail errors to a mailbox
  use Rack::MailExceptions
  
  # Enforce HTTPS
  use Rack::SSL
end

# All requests pass through the DF3 Rack app
# this is where the work happens
use DF3::RackApp

# URL not found? Server up a nice 404 page
run Rack::NotFound.new('public/404.html')
