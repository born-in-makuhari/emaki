require File.expand_path '../spec_helper.rb', __FILE__

# ===========================================================
# カスタムマッチャー
#

# desplay: セレクタ表記で要素を確定し、
#          値が１つの場合は要素があるか確認
#          値が２つの場合はテキストが同じか確認
#          値が３つの場合は要素の属性名・属性値が同じか確認
RSpec::Matchers.define :desplay do |css, keyortext, value|
  keyortext = keyortext.to_s unless keyortext.nil?
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

# ===========================================================
# Emaki specs
#

describe 'Emaki' do

  # 以降どんなサンプルでも、変数 html が lazy load で使える。
  let(:oga_html) { Oga.parse_html(last_response.body) }

  before :all do
    FileUtils.rm_rf(Binder.tmppath) if Binder.tmppath != '/'
  end

  # ---------------------------------------------------------
  # 共通テストケース
  #

  # ヘッダ、タイトル
  shared_examples_for 'common header' do
    it 'displays "emaki" as a link to "/"' do
      expect(oga_html).to desplay 'a#toTop', 'href', '/'
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

    it { expect(oga_html).to desplay @slide_css }
    it { expect(oga_html).to desplay '#next' }
    it { expect(oga_html).to desplay '#prev' }
    it { expect(oga_html).to desplay '#name' }
    it { expect(oga_html).to desplay '#title' }
    it { expect(oga_html).to desplay '#description' }
    it { expect(oga_html).to desplay '#nowNumber' }
    it 'desplays all pages, as <img>' do
      3.times do |i|
        expect(oga_html).to desplay @page_css[i]
        expect(oga_html).to desplay @img_css[i], :src, @img_href[i]
      end
    end

  end

  # リダイレクト
  shared_examples_for 'redirect' do |path|
    it { expect(last_response.redirect?).to be true }
    it { expect(last_response['Location']).to eq "http://example.org#{path}" }
  end

  # ユーザーがないこと
  shared_examples "does not create user #{UN}" do
    it { expect(User.exists?(UN)).to be false }
  end

  # スライドがないこと
  shared_examples "does not create slide #{SN}" do
    it { expect(Slide.exists?(UN, SN)).to be false }
  end

  # ---------------------------------------------------------
  # 個別テストケース
  #

  #
  # SLIDE PAGE
  # /username/slidename
  #
  describe 'GET /username/slidename' do
    context 'if target exists,' do
      include_context 'signed in', nil, :all
      include_context 'slide posted with'
      it_behaves_like 'an emaki page'
      it_behaves_like 'a slide page'

      before(:all) { get "/#{UN}/#{SN}" }

      after :all do
        FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
        FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
      end
    end

    context 'if target does not exist,' do
      include_context 'signed in', nil, :all
      it_behaves_like 'common header'

      before(:all) { get '/testuser/testslide' }

      it { expect(last_response.status).to eq 404 }
      it do
        expect(oga_html).to desplay(
          '#slideNotFound',
          '"testuser/testslide" Not Found.'
        )
      end
    end
  end

  # ---------------------------------------------------------
  # スライド画像へのルーティング
  #
  describe 'GET /:username/:slidename/:number.png' do
    include_context 'signed in', nil, :all
    include_context 'slide posted with'

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
