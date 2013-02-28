$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
Bundler.require

require 'json'
require 'sinatra'

require 'sqs/api'
SQS::API.setup(File.expand_path("../config/config.yml", File.dirname(__FILE__)))

require 'sqs/api/translator'

get '/' do
  redirect '/translate.html'
end

post '/translate' do
  ret = SQS::API::Translator.start(params)
  if ret[:code] == 200
    send_file ret[:file], type: params[:type], filename: ret[:filename]
  else
    ret.to_json
  end
end


