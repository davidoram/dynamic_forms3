# 
# Configure the Rack application
# 
require 'rack'
require 'rack/contrib'
require 'df3/projectapp'

use Rack::MethodOverride
use Rack::CommonLogger

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
else
  use Rack::MailExceptions
  use Rack::SSL
end

map "/projects" do
 use Rack::Lint
 use DF3::ProjectApp
end

run Rack::NotFound.new('public/404.html')
