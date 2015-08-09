require 'sinatra'
require 'slim'
require File.expand_path('../lib', __FILE__) + '/slide.rb'

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
  if Slide.exist?(params[:username], params[:slidename])
    slim :slide, layout: :layout
  else
    redirect to('/')
  end
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
