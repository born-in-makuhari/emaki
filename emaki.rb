require 'sinatra'
require 'slim'
require 'RMagick'

configure :production, :development do
  enable :logging
  file = File.new("#{settings.root}/logs/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

# ----------------------------------------------------------------
# TODO: ファイルを分割。
class Slide
  def self.logger
    @internal_logger ||= Rack::NullLogger.new nil
  end

  def self.makepath(un, sn)
    File.expand_path('../', __FILE__) + "/slides/#{un}/#{sn}"
  end

  def self.mkdir(un, sn, logger = self.logger)
    # TODO: It is too danger, I need another way
    # mkdir -p slides/#{un}/#{sn}
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

  def self.exist?(un, sn, logger = self.logger)
    FileTest.exist?(makepath(un, sn, logger))
  end
  # --------------------------------------------------------------
  # tmp/ にファイルを保存し、keyを返す
  def self.tmpsave(file, logger = self.logger)
    tmp
    key = maketmpkey(file[:filename])
    begin
      File.open(tmppath + '/' + key, 'wb') { |f| f.write file[:tempfile].read }
    rescue => e
      logger.error(e.message)
      return nil
    end
    key
  end

  def self.tmpremove(key)
    FileUtils.rm(tmppath + '/' + key)
  end

  def self.tmppath
    File.expand_path('../', __FILE__) + '/tmp'
  end

  # ./tmpを作成
  def self.tmp
    return true if FileTest.exist?(tmppath)
    FileUtils.mkdir(tmppath)
  end

  def self.maketmpkey(base)
    (0...8).map { (65 + rand(26)).chr }.join +
    '_' +
    Date.today.strftime('%Y%m%d%H%M%S') +
    base
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
  un = params[:username]
  sn = params[:slidename]
  file = params[:file]

  result = save_slide un, sn, file
  redirect to("/#{un}/#{sn}") if result
  redirect to('/new')
end

# 最終的に
get '/:username/:slidename' do
end

# ----------------------------------------------------------------
# Procs
# Routesの処理代行
#
def save_slide(un, sn, file)
  # 一時保存
  key = Slide.tmpsave(file, logger)
  return false unless key

  # ディレクトリないことを確認
  return false if Slide.exist?(un, sn, logger)
  # 作成失敗なら後処理は不要
  return false if Slide.mkdir(un, sn, logger)

  # PDFファイルを変換
  convert_pdf_to_png(Slide.tmppath + '/' + key, Slide.makepath(un, sn))
end

def convert_pdf_to_png(srcfilepath, destpath)
  begin
    images = Magick::Imagge.read(srcfilepath)
    images.each_with_index { |image, i| image[i].write("#{destpath}/#{i}.png") }
    return true
  rescue => e
    logger.error(e.message)
    Slide.rmdir(un, sn, logger)
  ensure
    Slide.tmpremove(key)
  end
end
