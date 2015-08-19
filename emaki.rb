require 'sinatra'
require 'slim'

EMAKI_ROOT = File.expand_path('../', __FILE__)

require EMAKI_ROOT + '/lib/slide.rb'

enable :sessions
configure :production, :development do
  enable :logging
  file = File.new("#{settings.root}/logs/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

# ----------------------------------------------------------------
# Routes
#
get '/' do

  # FIXME: DBがないので、ゴリ押しリスト表示する
  @slides = {}
  if FileTest.exist?(EMAKI_ROOT + '/slides')
    users = Dir.entries(EMAKI_ROOT + '/slides')
    users.each do |un|
      next if un == '.' || un == '..'
      slides = Dir.entries(EMAKI_ROOT + '/slides/' + un)
      @slides[un] = []
      slides.each do |sn|
        next if sn == '.' || sn == '..'
        @slides[un] << sn
      end
    end
  end
  # FIXME: ここまで

  slim :index, layout: :layout
end

get '/new' do
  @attention = session[:attention]
  session[:attention] = nil
  slim :new, layout: :layout
end

post '/slides' do
  un = params[:username]
  sn = params[:slidename]
  file = params[:slide]

  # slugは正当か？
  unless Slide.valid_slugs?(un, sn)
    session[:attention] = slim :slug_rule, layout: false
    redirect to('/new')
    return
  end

  unless file
    session[:attention] = slim :no_file, layout: false
    redirect to('/new')
    return
  end

  result = save_slide un, sn, file
  if result
    redirect to("/#{un}/#{sn}")
  else
    redirect to('/new')
  end
end

# マッチしなかったらスライドだと判断
get '/:username/:slidename' do
  if Slide.exist?(params[:username], params[:slidename])
    @un = params[:username]
    @sn = params[:slidename]
    @page_number = Slide.page_number @un, @sn
    @page_urls = Slide.page_urls @un, @sn
    slim :slide, layout: :layout
  else
    status 404
    @slide_name = "#{params[:username]}/#{params[:slidename]}"
    slim :slide_not_found
  end
end

# スライド画像の返却
get '/:username/:slidename/:number.png' do
  content_type :png
  path = Slide.makepath(params[:username], params[:slidename]) +
    "/#{params[:number]}.png"
  send_file path
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
