require 'sinatra'
require 'json'


get '/status.json' do
    content_type :json
    { :status => 'OK'}.to_json
end

get '/status' do
    'OK'
end

get '/' do
    'Example application'
end