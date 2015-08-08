require 'sinatra'
require 'slim'

get '/' do
  slim :index, layout: :layout
end

get '/new' do
  slim :new, layout: :layout
end
