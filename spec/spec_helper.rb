require 'rack/test'
require 'rspec'

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
