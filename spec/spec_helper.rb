require 'bundler'
Bundler.require :test
require 'capybara/rspec'
require 'rack_session_access/capybara'

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
Capybara::Webkit.configure do |config|
  config.allow_url('ajax.googleapis.com')
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
  Redis.current ||= Redis::Namespace.new(
    'emaki:test', host: '127.0.0.1', port: 6379)
  keys = Redis.current.keys 'emaki:test:*'
  keys.each do |k|
    Redis.current.del(k)
  end
end
flush_testdb!

# ---------------------------------------------------------
# 共通の事前条件

# スライドがある状態
#
# username:  trueの時は正しい形式
# slidename: 上に同じ
# file:      上に同じ
shared_context 'slide posted with' do |un, sn, file|
  un = un ? UN : '-'
  sn  = sn ? SN : '-'
  file = file ? PDF_FILE : nil

  let(:slide_path) { SLIDES_ROOT + "/#{un}/#{sn}" }

  before :all do
    flush_testdb!

    post_data = {
      title: 'タイトルの表示名はどんな形式でもいい',
      description: 'タイトルの説明はどんな形式でもいい',
      slidename: sn,
      slide: file
    }

    post '/slides', post_data
  end

  after :all do
    FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
    FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
    flush_testdb!
  end
end

#
# ユーザーがある状態
#
# info...UserモデルのプロパティをもつHash
shared_context 'user created' do |info|
  before do
    User.create(info).save
  end

  after do
    User.first(slug: info[:slug]).destroy
  end
end
