# ----------------------------------------------------------------
# Gems
#
require 'bundler'
Bundler.require

# ----------------------------------------------------------------
# Emaki::
#
EMAKI_ROOT = File.expand_path('../', __FILE__)
EMAKI_VERSION = 'ver 0.0.0'
EMAKI_ENV = ENV['RACK_ENV'] ? ENV['RACK_ENV'] : 'development'
DB_NAMESPACE = "emaki:#{EMAKI_ENV}"

puts <<"EOS"
+---------------------+
|   emaki #{EMAKI_VERSION}   |
+---------------------+
| environment:  #{EMAKI_ENV}
| db namespace: #{DB_NAMESPACE}
|
EOS

require EMAKI_ROOT + '/lib/binder.rb'
require EMAKI_ROOT + '/lib/models.rb'

enable :sessions
set :session_secret, 'emaki'
configure :production, :development do
  enable :logging
  file = File.new("#{settings.root}/logs/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end
# ----------------------------------------------------------------
# Database
#

# おまじない
adapter = DataMapper.setup(:default, adapter: 'redis')
adapter.resource_naming_convention = lambda do |value|
  [
    'emaki',
    EMAKI_ENV,
    DataMapper::Inflector.pluralize(
      DataMapper::Inflector.underscore(value)).gsub('/', '_')
  ].join(':')
end
# おまじないおわり

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
  un = params[:username]  # required
  sn = params[:slidename] # required
  name = params[:name]
  title = params[:title]
  description = params[:description]
  file = params[:slide]

  # slugは正当か？
  unless Binder.valid_slugs?(un, sn)
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
    # TODO: ユーザー作成機能をしかるべき場所へ移す。
    # ユーザーとスライドのレコードを作成する。
    # アカウント機能ができたら、ユーザーはここで作るべきではない
    User.create(slug: un, name: name)
    Slide.create(
      user_slug: un,
      slug: sn,
      title: title,
      description: description
    )

    redirect to("/#{un}/#{sn}")
  else
    redirect to('/new')
  end
end

# マッチしなかったらスライドだと判断
get '/:username/:slidename' do
  if Binder.exist?(params[:username], params[:slidename])
    @un = params[:username]
    @sn = params[:slidename]
    @page_number = Binder.page_number @un, @sn
    @page_urls = Binder.page_urls @un, @sn
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
  path = Binder.makepath(params[:username], params[:slidename]) +
    "/#{params[:number]}.png"
  send_file path
end

# ----------------------------------------------------------------
# Procs
# Routesの処理代行
#
def save_slide(un, sn, file)
  # 一時保存
  key = Binder.tmpsave(file, logger)
  return false unless key

  # ディレクトリないことを確認
  return false if Binder.exist?(un, sn)

  # 作成失敗なら後処理は不要
  return false unless Binder.mkdir(un, sn, logger)

  # PDFファイルを変換
  result = convert_pdf_to_png(un, sn,
                              Binder.tmppath + '/' + key,
                              Binder.makepath(un, sn))
  Binder.tmpremove(key, logger)
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
    Binder.rmdir(un, sn, logger)
    return false
  end
end
