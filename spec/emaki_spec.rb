require File.expand_path '../spec_helper.rb', __FILE__
require 'slim'

# テストで使うデータたち
PDF_PATH = SPEC_ROOT + '/test.pdf'

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

  # どんなサンプルでも、変数 html が lazy load で使える。
  let(:html) { Oga.parse_html(last_response.body) }

  before :all do
    FileUtils.rm_rf(Slide.tmppath) if Slide.tmppath != '/'
  end
  # ---------------------------------------------------------
  # 共通の事前条件
  #
  shared_context 'new slide posted with' do |username, slidename, file|
    if file
      file = Rack::Test::UploadedFile.new(PDF_PATH, 'application/pdf')
    else
      file = nil
    end

    let(:slide_path) { SLIDES_ROOT + "/#{UN}/#{SN}" }

    before :all do
      post_data = {
        username: username,
        slidename: slidename,
        slide: file
      }

      post '/slides', post_data
    end
  end

  # ---------------------------------------------------------
  # 共通テストケース
  #

  # ヘッダ、タイトル
  shared_examples_for 'common header' do
    it 'displays "emaki" as a link to "/"' do
      expect(html).to desplay 'a#toTop', 'href', '/'
    end
  end

  # 普通のページ
  shared_examples_for 'an emaki page' do
    it_behaves_like 'common header'
    it 'returns 200' do
      expect(last_response).to be_ok
    end
  end

  # スライドページ。
  shared_examples_for 'a slide page' do
    before :all do
      @slide_css = 'div#slideView'
      @page_css = []
      @img_css = []
      @img_href = []
      3.times do
        @page_css << "#{@slide_css} section#page#{@page_css.length}"
        @img_css  << "#{@page_css[@img_css.length]} img"
        @img_href << "/#{UN}/#{SN}/#{@img_href.length}.png"
      end
    end

    it { expect(html).to desplay @slide_css }
    it { expect(html).to desplay '#next' }
    it { expect(html).to desplay '#prev' }
    it 'desplays all pages, as <img>' do
      3.times do |i|
        expect(html).to desplay @page_css[i]
        expect(html).to desplay @img_css[i], :src, @img_href[i]
      end
    end
  end

  # ---------------------------------------------------------
  # 個別テストケース
  #

  #
  #  /
  #
  describe 'GET /' do
    it_behaves_like 'an emaki page'
    before(:all) { get '/' }
    it { expect(html).to desplay 'a#toNew', 'href', '/new' }
  end

  #
  #  /new
  #
  describe 'GET /new' do
    it_behaves_like 'an emaki page'
    before(:all) { get '/new' }
    describe 'html' do
      form = 'form#newSlide'
      uninput = 'input#username'
      sninput = 'input#slidename'
      slinput = 'input#slide'
      it { expect(html).to desplay form }
      it { expect(html).to desplay form, :action, '/slides' }
      it { expect(html).to desplay form, :method, 'post' }
      it { expect(html).to desplay form, :enctype, 'multipart/form-data' }
      it { expect(html).to desplay uninput, :type, 'text' }
      it { expect(html).to desplay uninput, :name, 'username' }
      it { expect(html).to desplay sninput, :type, 'text' }
      it { expect(html).to desplay sninput, :name, 'slidename' }
      it { expect(html).to desplay slinput, :type, 'file' }
      it { expect(html).to desplay slinput, :name, 'slide' }
      it { expect(html).to desplay 'input[type="submit"]' }
    end
  end

  #
  # SLIDE PAGE
  # /username/slidename
  #
  describe 'GET /username/slidename' do
    context 'if target exists,' do
      include_context 'new slide posted with', UN, SN, true
      it_behaves_like 'an emaki page'
      it_behaves_like 'a slide page'

      before :all do
        get '/testuser/testslide'
      end

      after :all do
        FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
        FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
      end
    end

    context 'if target does not exist,' do
      it_behaves_like 'common header'

      before :all do
        get '/testuser/testslide'
      end

      it { expect(last_response.status).to eq 404 }
      it do
        expect(html).to desplay(
          '#slideNotFound',
          '"testuser/testslide" Not Found.'
        )
      end
    end
  end

  #
  # /slides
  #
  describe 'POST /slides' do
    context 'if username is invalid,' do
      include_context 'new slide posted with', '-', SN, true

      it 'redirects to "/new"' do
        expect(last_response.redirect?).to be true
        expect(last_response['Location']).to eq 'http://example.org/new'
      end

      context 'follow redirect,' do
        let(:html) { Oga.parse_html(last_response.body) }
        before { follow_redirect! }

        it 'with slug rules' do
          expect(html).to desplay '#attention #slugRule'
        end
      end
    end

    context 'if slidename is invalid,' do
      include_context 'new slide posted with', UN, '-', true

      it 'redirects to "/new"' do
        expect(last_response.redirect?).to be true
        expect(last_response['Location']).to eq 'http://example.org/new'
      end

      context 'follow redirect,' do
        let(:html) { Oga.parse_html(last_response.body) }
        before { follow_redirect! }

        it 'with slug rules' do
          expect(html).to desplay '#attention #slugRule'
        end
      end
    end

    context 'no file,' do
      include_context 'new slide posted with', UN, SN, false

      it 'redirects to "/new" with no_file' do
        expect(last_response.redirect?).to be true
        expect(last_response['Location']).to eq 'http://example.org/new'
      end

      context 'follow redirect,' do
        let(:html) { Oga.parse_html(last_response.body) }
        before { follow_redirect! }
        it 'with no file attention' do
          expect(html).to desplay '#attention #noFile'
        end
      end
    end

    context "{ username: '#{UN}', slidename: '#{SN}', file: './test.pdf' }" do
      include_context 'new slide posted with', UN, SN, true

      after :all do
        FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
        FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
      end

      it "redirects to /#{UN}/#{SN}" do
        expect(last_response.redirect?).to be true
        expect(last_response['Location']).to eq "http://example.org/#{UN}/#{SN}"
      end

      it "creates directory slides/#{UN}/#{SN}" do
        expect(FileTest.exist? slide_path).to be true
      end

      it 'creates png images in the directory' do
        expect(FileTest.exist? slide_path + '/0.png').to be true
        expect(FileTest.exist? slide_path + '/1.png').to be true
        expect(FileTest.exist? slide_path + '/2.png').to be true
      end

      it 'cleanup /tmp' do
        expect(Dir.entries(Slide.tmppath).join).to eq '...'
      end
    end
  end
  # ---------------------------------------------------------
  # スライド画像へのルーティング
  #
  describe 'GET /:username/:slidename/:number.png' do
    include_context 'new slide posted with', UN, SN, true

    after :all do
      FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
      FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
    end

    3.times do |number|
      context "page #{number}" do
        before { get "/#{UN}/#{SN}/#{number}.png" }
        it { expect(last_response).to be_ok }
        it { expect(last_response['Content-Type']).to eq 'image/png' }
      end
    end
  end

end
