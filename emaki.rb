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
# Attention system
#

before do
  @attention = session[:attention]
  session[:attention] = nil
end

# ----------------------------------------------------------------
# Guest only
#
# ログインしているユーザーは
# メッセージとともにTOPへリダイレクト

before '*' do |path|
  target = ['/users', '/register', '/signin']
  if session[:user] && target.include?(path)
    session[:attention] = slim :only_guest, layout: false
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
  # スラグが不正だったらこの時点で終了
  unless Binder.valid_slug? slug
    session[:attention] = slim :slug_rule, layout: false
    redirect to '/register'
    return
  end

  # ユーザーを登録
  @user = User.create(slug: slug, name: name, password: password, email: email)
  if @user.save
    session[:attention] = slim :welcome_user, layout: false
    redirect to '/'
  else
    # TODO: 理由を表示する
    # TODO: 値を保持
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
    redirect to '/signin'
    return
  end

  # パスワードあってなかったら戻る
  if user.password != password
    redirect to '/signin'
    return
  end

  # ユーザーあったらログイン状態
  session[:user] = user.slug
  redirect to '/'
end

get '/signout' do
  session[:user] = nil
  redirect to '/'
end

post '/slides' do
  sn = params[:slidename] # required
  title = params[:title]
  description = params[:description]
  file = params[:slide]

  # slugは正当か？
  unless Binder.valid_slug?(sn)
    session[:attention] = slim :slug_rule, layout: false
    redirect to('/new')
    return
  end

  unless file
    session[:attention] = slim :no_file, layout: false
    redirect to('/new')
    return
  end

  # TODO: ユーザー名はセッションから取得する
  un = 'testuser'
  User.create(slug: 'testuser') if User.first(slug: 'testuser').nil?
  # TODO: ここまで

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
    session[:attention] = 'ユーザーがいません。'
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
