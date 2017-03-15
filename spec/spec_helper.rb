require 'bundler'
Bundler.require :test
require 'capybara/rspec'

headless = Headless.new
headless.start

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../emaki.rb', __FILE__

# add definitions
module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }

# ---------------------------------------------------------
# For Capybara
Capybara.app = Sinatra::Application
Capybara.current_driver = :webkit
Capybara.javascript_driver = :webkit
Capybara::Webkit.configure do |config|
  config.allow_url('ajax.googleapis.com')
  config.allow_url('fonts.googleapis.com')
end
# ---------------------------------------------------------
# Test data
UN = 'testuser'
SN = 'testslide'

SPEC_ROOT = File.expand_path('../', __FILE__)
SLIDES_ROOT = File.expand_path('../../', __FILE__) + '/slides'

PDF_PATH = SPEC_ROOT + '/test.pdf'
PDF_TYPE = 'application/pdf'
PDF_FILE = Rack::Test::UploadedFile.new(PDF_PATH, PDF_TYPE)

def session
  last_request.env['rack.session']
end

# 全てのテストデータを削除
# TODO: もっといいやりかた
def flush_testdb!
  Slide.all.destroy
  User.all.destroy
end
flush_testdb!

# ---------------------------------------------------------
# 共通の事前条件

# スライドがある状態
#
# username:  指定されなければ正しい形式(UN)
# slidename: 指定されなければ正しい形式(SN)
# file:      指定されなければ正しい形式(PDF_FILE)
shared_context 'slide posted with' do |un, sn, file, all|
  un = un ? un : UN
  sn  = sn ? sn : SN
  file = file ? file : PDF_FILE
  all ||= :all

  let(:slide_path) { SLIDES_ROOT + "/#{un}/#{sn}" }

  before all do
    post_data = {
      title: 'タイトルの表示名はどんな形式でもいい',
      description: 'タイトルの説明はどんな形式でもいい',
      slidename: sn,
      slide: file
    }

    post '/slides', post_data
  end

  after all do
    Slide.first(slug: sn).destroy if Slide.first(slug: sn)
    FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
    FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
    flush_testdb!
  end
end

shared_context 'slide posted with each case' do |un, sn, file|
  include_context 'slide posted with', un, sn, file, :each
end

#
# ユーザーがある状態
#
# info...UserモデルのプロパティをもつHash
def sample_user
  {
    slug: UN,
    name: UN,
    email: UN + '@test.com',
    password: 'password'
  }
end

shared_context 'user created' do |info, all|
  all ||= :each
  info ||= sample_user
  before(all) { User.create(info).save }
  after all do
    User.first(slug: info[:slug]).destroy if User.first(slug: info[:slug])
  end
end

shared_context 'signed in' do |info, all|
  all ||= :each
  info ||= sample_user
  include_context 'user created', info, all
  before all do
    post '/signin',
         username_or_email: info[:slug],
         password: info[:password]
  end
end

shared_context 'signed out' do |all|
  all ||= :each
  before(all) { get '/signout' }
end
