require 'rubygems'
require 'bundler'
require 'json'

Bundler.require
require 'sinatra'

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
require 'sqs/api'

SQS::API.setup(File.expand_path("../config/config.yml", File.dirname(__FILE__)))

get '/' do
  "Hello World"
end

post '/translate' do
  ret = SQS::API::Translator.start(params)
  if ret[:code] == 200
    content_type ret[:type]
    ret[:file]
  else
    ret.to_json
  end
end


