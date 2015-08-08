require File.expand_path '../spec_helper.rb', __FILE__

describe 'Emaki' do
  describe 'GET /' do
    before { get '/' }
    it 'returns 200' do
      expect(last_response).to be_ok
    end
  end
  describe 'GET /new' do
    before { get '/new' }
    it 'returns 200' do
      expect(last_response).to be_ok
    end
    it 'contains <form>' do
      pending 'not yet'
    end
    it 'contains <input type="text" name="username">' do
      pending 'not yet'
    end
    it 'contains <input type="text" name="slidename">' do
      pending 'not yet'
    end
    it 'contains <input type="submit">' do
      pending 'not yet'
    end
  end
  describe 'POST /slides' do
    before do
      # TODO: refresh slides/ directory
      post '/slides'
    end
    it 'redirects to /testuser/testslide' do
      pending 'not yet'
    end
    it 'creates directory "slides/testuser/testslide"' do
      pending 'not yet'
    end
    it 'creates png images in the directory' do
      pending 'not yet'
    end
  end
end
