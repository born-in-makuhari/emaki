require File.expand_path '../spec_helper.rb', __FILE__

describe 'Emaki' do
  describe 'GET /' do
    before { get '/' }
    it 'returns 200' do
      expect(last_response).to be_ok
    end
  end
  describe 'GET /new' do
    before do
      get '/new'
      @html = Oga.parse_html(last_response.body)
    end
    describe 'then' do
      it 'returns 200' do
        expect(last_response).to be_ok
      end
      it 'contains form#newSlide' do
        expect(@html.at_css('form#newSlide')).not_to be nil
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
