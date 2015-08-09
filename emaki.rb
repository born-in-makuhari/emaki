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
      logger.error(e.message + e.backtrace[0])
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
      logger.error(e.message + e.backtrace[0])
      return false
    end

    path
  end

  def self.exist?(un, sn)
    FileTest.exist?(makepath(un, sn))
  end
  # --------------------------------------------------------------
  # tmp/ にファイルを保存し、keyを返す
  def self.tmpsave(file, logger = self.logger)
    tmp
    key = maketmpkey(file[:filename])
    begin
      File.open(tmppath + '/' + key, 'wb') { |f| f.write file[:tempfile].read }
    rescue => e
      logger.error(e.message + e.backtrace[0])
      return nil
    end
    key
  end

  def self.tmpremove(key, logger = self.logger)
    path = tmppath + '/' + key
    begin
      FileUtils.remove path
    rescue => e
      logger.error('tmpremove failed.')
      logger.error(e.message + e.backtrace[0])
    end
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
    Time.now.strftime('%Y%m%d%H%M%S') +
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
  file = params[:slide]

  result = save_slide un, sn, file
  if result
    redirect to("/#{un}/#{sn}")
  else
    redirect to('/new')
  end
end

# マッチしなかったらスライドだと判断
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
  return false if Slide.exist?(un, sn)

  # 作成失敗なら後処理は不要
  return false unless Slide.mkdir(un, sn, logger)

  # PDFファイルを変換
  result = convert_pdf_to_png(un, sn,
                              Slide.tmppath + '/' + key, Slide.makepath(un, sn))
  Slide.tmpremove(key, logger)
  result
end

def convert_pdf_to_png(un, sn, srcfilepath, destpath)
  begin
    Magick::Image.read(srcfilepath).each_with_index do |image, i|
      image.write("#{destpath}/#{i}.png")
    end
    return true
  rescue => e
    logger.error(e.message + e.backtrace[0])
    Slide.rmdir(un, sn, logger)
    return false
  end
end
