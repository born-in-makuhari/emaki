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
      puts "tmpsave! #{tmppath}/#{key}"
    rescue => e
      logger.error(e.message)
      return nil
    end
    key
  end

  def self.tmpremove(key, logger = self.logger)
    path = tmppath + '/' + key
    puts "[save_slide] tmpremove #{path}"
    begin
      FileUtils.remove path
    rescue => e
      puts "[save_slide] tmpremove error"
      logger.error('tmpremove failed.')
      logger.error(e.message)
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
  puts "[save_slide] result: #{result}"
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
  puts "[save_slide] #{un}, #{sn}, #{file}"
  # 一時保存
  key = Slide.tmpsave(file, logger)
  puts "[save_slide] key is #{key}"
  return false unless key

  # ディレクトリないことを確認
  return false if Slide.exist?(un, sn)

  puts "[save_slide] dir doesnot exist"
  # 作成失敗なら後処理は不要
  return false unless Slide.mkdir(un, sn, logger)

  puts "[save_slide] convert start"

  # PDFファイルを変換
  result = convert_pdf_to_png(un, sn, Slide.tmppath + '/' + key, Slide.makepath(un, sn))
  puts "convert_pdf_to_png returns #{result}"
  Slide.tmpremove(key, logger)
  return result
end

def convert_pdf_to_png(un, sn, srcfilepath, destpath)
  begin
    puts "[save_slide] #{un}/#{sn}"
    puts "[save_slide] #{srcfilepath} -> #{destpath}/#.png"
    images = Magick::Image.read(srcfilepath)
    puts "[save_slide] images.length: #{images.length}"
    images.each_with_index {
      |image, i| image[i].write("#{destpath}/#{i}.png")
    }
    return true
  rescue => e
    puts "[save_slide] convert error #{e.message}"
    logger.error(e.message)
    Slide.rmdir(un, sn, logger)
    return false
  end
end
