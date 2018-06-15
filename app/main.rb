require 'sinatra/base'
require 'json'

class SimpleApp < Sinatra::Base

    get '/example/status.json' do
        content_type :json
        { :status => 'OK'}.to_json
    end

    get '/status' do
        'OK'
    end

    get '/example/hello' do
        'Example application'
    end