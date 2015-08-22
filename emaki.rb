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

  # TODO: 全件表示しているけどそれでいいんですか？
  @slides = {}
  all_slides = Slide.all
  all_slides.each do |s|
    u = User.first(slug: s.user_slug)
    next unless u
    k = u.name ? u.name : u.slug
    v = s.title ? s.title : s.slug
    @slides[u.slug] ||= []
    @slides[u.slug] << { slug: s.slug, name: k, title: v }
  end
  # TODO: ここまで

  slim :index, layout: :layout
end

get '/new' do
  @attention = session[:attention]
  session[:attention] = nil
  slim :new, layout: :layout
end

get '/register' do
  slim :register, layout: :layout
end

post '/users' do
  slug = params[:username]
  name = params[:name]
  password = params[:password]
  email = params[:email]
  # ユーザーを登録
  User.create(slug: slug, name: name, password: password, email: email)
  redirect to '/'
end

get '/signin' do
  slim :signin, layout: :layout
end

post '/slides' do
  # TODO: ユーザー登録はここじゃない
  un = params[:username]  # required
  sn = params[:slidename] # required
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
    # スライドを作成
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

# SLIDE PAGE
# マッチしなかったらスライドだと判断
get '/:username/:slidename' do
  unless Binder.exist?(params[:username], params[:slidename])
    status 404
    @slide_name = "#{params[:username]}/#{params[:slidename]}"
    return slim :slide_not_found, layout: :layout
  end
  @un = params[:username]
  @sn = params[:slidename]

  @user = User.first slug: @un
  @slide = Slide.first user_slug: @un, slug: @sn

  if @user.nil? || @slide.nil?
    status 404
    @slide_name = "#{params[:username]}/#{params[:slidename]}"
    return slim :slide_not_found, layout: :layout
  end

  @page_number = Binder.page_number @un, @sn
  @page_urls = Binder.page_urls @un, @sn
  slim :slide, layout: :layout
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
