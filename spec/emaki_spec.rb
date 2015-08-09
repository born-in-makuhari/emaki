require File.expand_path '../spec_helper.rb', __FILE__

# ===========================================================
# カスタムマッチャー
#

# desplay: セレクタ表記で要素を確定し、
#          値が１つの場合は要素があるか確認
#          値が２つの場合はテキストが同じか確認
#          値が３つの場合は要素の属性名・属性値が同じか確認
RSpec::Matchers.define :desplay do |css, keyortext, value|
  match do |actual|
    if keyortext.nil?
      actual.at_css(css)
    elsif value.nil?
      actual.at_css(css).text == keyortext
    else
      actual.at_css(css).get(keyortext) == value
    end
  end
end

# have_attribute: セレクタ表記で要素を確定、
#                 属性名と値がマッチしたら成功
RSpec::Matchers.define :have_arrtibute do |css, key, value|
  match { |actual| actual.at_css(css).get(key) == value }
end

# ===========================================================
# Emaki specs
#

describe 'Emaki' do
  before :all do
    FileUtils.rm_rf(Slide.tmppath) if Slide.tmppath != '/'
  end

  # ---------------------------------------------------------
  # 共通テストケース
  #

  # 普通のページ。ヘッダ、タイトル、などなど
  shared_examples_for 'an emaki page' do
    it 'displays "emaki" as a link to "/"' do
      expect(html).to desplay 'a#toTop', 'emaki'
      expect(html).to desplay 'a#toTop', 'href', '/'
    end
    it 'returns 200' do
      expect(last_response).to be_ok
    end
  end

  # スライドページ。
  shared_examples_for 'a slide page' do
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
      it '         form#newSlide enctype="multipart/form-data"' do
        expect(@html.at_css('form#newSlide').get(:enctype))
          .to eq 'multipart/form-data'
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
      it 'contains <input id="slide" type="file" name="slide">' do
        target = @html.at_css('input#slide')
        expect(target.get(:type)).to eq 'file'
        expect(target.get(:name)).to eq 'slide'
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
    it_behaves_like 'an emaki page'
    it_behaves_like 'a slide page'
    let(:html) { @html }

    before do
      pdf_path = SPEC_ROOT + '/test.pdf'
      @d = { username: UN, slidename: SN,
        slide: Rack::Test::UploadedFile.new(pdf_path, 'application/pdf') }
      @path = Slide.makepath @d[:username], @d[:slidename]
      post '/slides', @d
      get '/testuser/testslide'
      @html = Oga.parse_html(last_response.body)
    end

    after do
      Slide.rmdir UN, SN
    end
  end

  #
  # /slides
  #

  # TODO: POST /slides は成功したら個別スライドページを返却するので
  # /username/slidename のテストケースを読み込んで使う予定
  describe 'POST /slides' do
    context "{ username: '#{UN}', slidename: '#{SN}', file: './test.pdf' }" do
      before do
        pdf_path = SPEC_ROOT + '/test.pdf'
        @d = { username: UN, slidename: SN,
          slide: Rack::Test::UploadedFile.new(pdf_path, 'application/pdf') }
        @path = Slide.makepath @d[:username], @d[:slidename]
        post '/slides', @d
      end

      after do
        Slide.rmdir UN, SN
      end

      it "redirects to /#{UN}/#{SN}" do
        expect(last_response.redirect?).to be true
        expect(last_response['Location']).to eq "http://example.org/#{UN}/#{SN}"
      end

      it "creates directory slides/#{UN}/#{SN}" do
        expect(FileTest.exist? @path).to be true
      end

      it 'creates png images in the directory' do
        expect(FileTest.exist? @path + '/0.png').to be true
        expect(FileTest.exist? @path + '/1.png').to be true
        expect(FileTest.exist? @path + '/2.png').to be true
      end

      it 'cleanup /tmp' do
        puts Slide.tmppath
        expect(Dir.entries(Slide.tmppath).join).to eq '...'
      end
    end
  end

end
