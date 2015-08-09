require File.expand_path '../spec_helper.rb', __FILE__

describe 'Emaki' do

  # ---------------------------------------------------------
  # 共通テストケース
  #

  # 普通のページ。ヘッダ、タイトル、などなど
  shared_examples_for 'an emaki page' do
    it 'displays "emaki" as a link to "/"' do
      target = html.at_css 'a#toTop'
      expect(target.text).to eq 'emaki'
      expect(target.get(:href)).to eq '/'
    end
    it 'returns 200' do
      expect(last_response).to be_ok
    end
  end

  # スライドページ。
  shared_examples_for 'a slide page' do
    pending
  end

  # ---------------------------------------------------------
  # 個別テストケース
  #

  #
  #  /
  #
  describe 'GET /' do
    it_behaves_like 'an emaki page'
    let(:html) { @html }
    before do
      get '/'
      @html = Oga.parse_html(last_response.body)
    end
    it 'links to "/new"' do
      target = @html.at_css('a#toNew')
      expect(target.get(:href)).to eq '/new'
    end
  end

  #
  #  /new
  #
  describe 'GET /new' do
    it_behaves_like 'an emaki page'
    let(:html) { @html }
    before do
      get '/new'
      @html = Oga.parse_html(last_response.body)
    end
    describe 'then' do
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

  #
  # SLIDE PAGE
  # /username/slidename
  #
  describe 'GET /username/slidename' do
    pending
    before do
      # TODO: refresh slides/ directory
      get '/testuser/testslide'
    end
  end

  #
  # /slides
  #

  # POST /slides はつまるところ 個別スライドページを返却するので
  # /username/slidename のテストケースを読み込んでます。
  describe 'POST /slides' do
    context 'with { username: testuser, slidename: testslide }' do
      before do
        data = { username: 'testuser', slidename: 'testslide' }
        Slide.rmdir data[:username], data[:slidename]
        @path = Slide.makepath data[:username], data[:slidename]
        post '/slides'
      end
      it 'redirects to /testuser/testslide'
      it 'creates directory "slides/testuser/testslide"' do
        puts @path
        expect(FileTest.exist? @path).to be true
      end
      it 'creates png images in the directory'
    end
  end
end
