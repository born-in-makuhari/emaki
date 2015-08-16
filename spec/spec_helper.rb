require 'bundler'
Bundler.require :test

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
  puts '| test db flushed !'
  `redis-cli KEYS "emaki:test:*" | xargs redis-cli DEL`
end
flush_testdb!
