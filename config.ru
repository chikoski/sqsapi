require 'app/sqsapi'

set :public_folder, File.expand_path("public")
run Sinatra::Application
