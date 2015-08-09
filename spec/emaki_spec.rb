require File.expand_path '../spec_helper.rb', __FILE__

describe 'Emaki' do
  describe 'GET /' do
    before do
      get '/'
      @html = Oga.parse_html(last_response.body)
    end
    it 'returns 200' do
      expect(last_response).to be_ok
    end
    it 'displays "emaki" as a link to "/"' do
      target = @html.at_css('a#toEmaki')
      expect(target.text).to eq 'emaki'
      expect(target.get(:href)).to eq '/'
    end
    it 'links to "/new"' do
      target = @html.at_css('a#toNew')
      expect(target.get(:href)).to eq '/new'
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
      it '         form#newSlide action="/slides"' do
        expect(@html.at_css('form#newSlide').get(:action)).to eq '/slides'
      end
      it '         form#newSlide method="post"' do
        expect(@html.at_css('form#newSlide').get(:method)).to eq 'post'
      end
      it 'contains <input id="username" type="text" name="username">' do
        target = @html.at_css('input#username')
        expect(target.get(:type)).to eq 'text'
        expect(target.get(:name)).to eq 'username'
      end
      it 'contains <input id="slidename" type="text" name="slidename">' do
        target = @html.at_css('input#slidename')
        expect(target.get(:type)).to eq 'text'
        expect(target.get(:name)).to eq 'slidename'
      end
      it 'contains <input type="submit">' do
        target = @html.at_css('input[type="submit"]')
        expect(target).not_to be nil
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
