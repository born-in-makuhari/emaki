require 'rack/test'
require 'rspec'
require 'oga'

require File.expand_path '../../emaki.rb', __FILE__

ENV['RACK_ENV'] = 'test'

# add definitions
module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }

UN = 'testuser'
SN = 'testslide'

SPEC_ROOT = File.expand_path('../', __FILE__)

def session
  last_request.env['rack.session']
end
