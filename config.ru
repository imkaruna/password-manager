require './config/environment.rb'


use Rack::MethodOverride
run ApplicationController
