require 'rubygems'
require 'bundler'

Bundler.require
require 'sinatra'

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
require 'sqs/api'

SQS::API.setup(File.expand_path("../config/config.yml", File.dirname(__FILE__)))

get '/' do
  "Hello World"
end

post '/translate' do
  SQS::API::Translator.start(params)
end

