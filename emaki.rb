# ----------------------------------------------------------------
# Gems
#
require 'bundler'
Bundler.require
Encoding.default_external = 'UTF-8'
set :bind, '0.0.0.0'

require 'sinatra/reloader' if development?

# ----------------------------------------------------------------
# Emaki::
#
# TODO: config.ruを使うべき
# TODO: そろそろクラシックスタイルからモジュールに切り替えるべき
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

require EMAKI_ROOT + '/lib/helpers.rb'
require EMAKI_ROOT + '/lib/binder.rb'

set :protection, false
set :protect_from_csrf, false

expire_after = 30 * 24 * 60 * 60 # production keeps 1 month
if EMAKI_ENV == 'development'
  expire_after = 12 * 60 * 60  # for dev: 12 hours
elsif EMAKI_ENV == 'test'
  expire_after = 0.1 * 60 * 60 # for test: 6 minutes
end
use Rack::Session::Pool, expire_after: expire_after,
                          secret: 'emaki'

if EMAKI_ENV != 'test'
  use Rack::Protection
  use Rack::Protection::FormToken
end

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
db_name = 'emaki'
if EMAKI_ENV == 'test'
  db_name = 'emaki_test'
end
adapter = DataMapper.setup(:default,
                           "postgres://emaki:emakipostgres@db/#{db_name}")
# adapter.resource_naming_convention = lambda do |value|
#  [
#    'emaki',
#    EMAKI_ENV,
#    DataMapper::Inflector.pluralize(
#      DataMapper::Inflector.underscore(value)).gsub('/', '_')
#  ].join(':')
# end
# おまじないおわり

require EMAKI_ROOT + '/models/models.rb'
# ----------------------------------------------------------------
# Implicit functions
#
# 暗黙的な処理。
# 最後の入力値をリダイレクト先に次に引き継いだり、
# 注意書きをリダイレクト先に引き継いだり

before do
  load_attention
end

after do
  save_last
end

# ----------------------------------------------------------------
# Named user only
#
# ログインしていないユーザーは
# メッセージとともにTOPへリダイレクト

before '*' do |path|
  target = ['/new', '/slides']
  if target.include?(path) && session[:user].nil?
    attention :only_named_user
    redirect to '/'
  end
end

# ----------------------------------------------------------------
# Guest only
#
# ログインしているユーザーは
# メッセージとともにTOPへリダイレクト

before '*' do |path|
  target = ['/users', '/register', '/signin']
  if target.include?(path) && session[:user]
    attention :only_guest
    redirect to '/'
  end
end

# ----------------------------------------------------------------
# Routes
#

get '/' do
  # TODO: 全件表示しているけどそれでいいんですか？
  @slides = {}
  all_slides = Slide.all
  all_slides.each do |s|
    u = s.user
    next unless u
    k = u.name ? u.name : u.slug
    v = s.title ? s.title : s.slug
    @slides[u.slug] ||= []
    @slides[u.slug] << { slug: s.slug, name: k, title: v }
  end
  # TODO: ここまで

  # index.jsを読み込む
  @js = [:index]
  slim :index, layout: :layout
end

get '/new' do
  slim :new, layout: :layout
end

get '/register' do
  slim :register, layout: :layout
end

get '/users/:username' do
  @user = User.first(slug: params[:username])
  unless @user
    status 404
    return slim :"attentions/user_not_found", layout: :layout
  end

  @slides = @user.slides
  slim :user_page, layout: :layout
end

post '/users' do
  slug = params[:username]
  name = params[:name]
  password = params[:password]
  email = params[:email]
  # スラグが不正だったらこの時点で終了
  unless Binder.valid_slug? slug
    attention :slug_rule
    redirect to '/register'
    return
  end

  # ユーザーID被ってたら警告して終了
  if User.all(slug: slug).length != 0
    attention :slug_dupl
    redirect to '/register'
  end

  # ユーザーを登録
  @user = User.create(slug: slug, name: name, password: password, email: email)

  if @user.save
    # 自動でログイン
    session[:user] = slug
    attention :welcome_user
    redirect to '/'
  else
    attention :user_rule
    redirect to '/register'
  end
end

get '/signin' do
  slim :signin, layout: :layout
end

post '/signin' do
  # emailかどうか、「＠」で判断する
  u_o_e = params[:username_or_email]
  password = params[:password]

  user = nil
  if u_o_e.include? '@'
    user = User.first(email: u_o_e)
  else
    user = User.first(slug: u_o_e)
  end

  # ユーザーなかったら戻る
  if user.nil?
    attention :user_not_found
    redirect to '/signin'
    return
  end

  # パスワードあってなかったら戻る
  if user.password != password
    attention :user_not_found
    redirect to '/signin'
    return
  end

  # ユーザーあったらログイン状態
  session[:user] = user.slug
  redirect to '/'
end

get '/signout' do
  session[:user] = nil
  attention :goodbye_user
  redirect to '/'
end

post '/slides' do
  sn = params[:slidename] # required
  title = params[:title]
  description = params[:description]
  file = params[:slide]
  ignore_last :slide

  # slugは正当か？
  unless Binder.valid_slug?(sn)
    attention :slug_rule
    redirect to('/new')
    return
  end

  unless file.class == Hash
    attention :no_file
    redirect to('/new')
    return
  end

  # ユーザー名はセッションから取得する
  un = session[:user]

  result = save_slide un, sn, file
  if result
    user = User.first(slug: un)
    # スライドを作成
    Slide.create(
      user: user,
      slug: sn,
      title: title,
      description: description
    )

    redirect to("/#{un}/#{sn}")
  else
    # TODO: もうちょっと親切にする
    session[:attention] = '投稿に失敗しました'
    redirect to('/new')
  end
end

# SLIDE PAGE
# マッチしなかったらスライドだと判断
get '/:username/:slidename' do
  unless Binder.exist?(params[:username], params[:slidename])
    status 404
    @slide_name = "#{params[:username]}/#{params[:slidename]}"
    return slim :"attentions/slide_not_found", layout: :layout
  end
  @un = params[:username]
  @sn = params[:slidename]

  @user = User.first slug: @un
  @slide = Slide.first user: @user, slug: @sn

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
