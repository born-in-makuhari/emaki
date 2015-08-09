require 'sinatra'
require 'slim'

# TODO: It is too danger, I need another way
# mkdir -p slides/#{un}/#{sn}
def mkdir_slides(un, sn)
  return false if un.nil? || sn.nil?

  begin
    logger.info File.expand_path('.', __FILE__) + "slides/#{un}/#{sn}"
    #Dir.mkdir File.expand_path('.', __FILE__) + "slides/#{un}/#{sn}"
  rescue => e
    logger.error e
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
