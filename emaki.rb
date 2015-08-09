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
  def self.logger
    @internal_logger ||= Rack::NullLogger.new nil
  end

  def self.makepath(un, sn)
    File.expand_path('../', __FILE__) + "/slides/#{un}/#{sn}"
  end

  def self.mkdir(un, sn, logger = self.logger)
    return false if un.nil? || sn.nil?
    path = makepath(un, sn)
    logger.info("MKDIR #{path}")
    begin
      FileUtils.mkdir_p path
    rescue => e
      logger.error(e.message)
      return false
    end

    path
  end

  def self.rmdir(un, sn, logger = self.logger)
    return false if un.nil? || sn.nil?
    path = makepath(un, sn)
    logger.info("RMDIR #{path}")
    begin
      FileUtils.rmdir path
    rescue => e
      logger.error(e.message)
      return false
    end

    path
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
  ok = Slide.mkdir params[:username], params[:slidename], logger
  redirect to('/testuser/testslide') if ok
  redirect to('/new')
end
