$LOAD_PATH << File.expand_path("app", File.dirname(__FILE__))
require 'app/sqsapi'

set :public_folder, File.expand_path("public")
run Sinatra::Application
