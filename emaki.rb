require 'sinatra'
require 'slim'

configure :production, :development do
  enable :logging
  file = File.new("#{settings.root}/logs/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

# ----------------------------------------------------------------
# TODO: It is too danger, I need another way
# mkdir -p slides/#{un}/#{sn}
class Slide
  def makepath(un, sn)
    File.expand_path('../', __FILE__) + "/slides/#{un}/#{sn}"
  end

  def self.mkdir(un, sn)
    return false if un.nil? || sn.nil?
    path = makepath(un, sn)
    logger.info "MKDIR #{path}"
    begin
      Dir.mkdir path
    rescue => e
      logger.error e
      return false
    end

    true
  end

  def self.rmdir(un, sn)
    return false if un.nil? || sn.nil?
    path = makepath(un, sn)
    logger.info "RMDIR #{path}"
    begin
      FileUtils.rmdir path
    rescue => e
      logger.error e
      return false
    end

    true
  end
end
# ----------------------------------------------------------------
# Routes
#
get '/' do
  slim :index, layout: :layout
end

get '/new' do
  slim :new, layout: :layout
end

post '/slides' do
  Slide.mkdir params[:username], params[:slidename]
  redirect to('/testuser/testslide')
end
