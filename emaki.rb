require 'sinatra'
require 'slim'

# TODO: It is too danger, I need another way
# mkdir -p slides/#{un}/#{sn}
def mkdir_slides(un, sn)
  return false if un.nil? || sn.nil?

  begin
    Dir.mkdir("slides/#{un}/#{sn}")
  rescue => e
    puts(e)
    return false
  end

  true
end

get '/' do
  slim :index, layout: :layout
end

get '/new' do
  slim :new, layout: :layout
end

post '/slides' do
  redirect to('/testuser/testslide')
end
