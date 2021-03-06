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
  #  /
  #
  describe 'GET /' do
    before(:all) { get '/' }
    it_behaves_like 'an emaki page'
  end

  #
  # /register
  #
  describe 'GET /register' do
    context 'if not signed in,' do
      it_behaves_like 'an emaki page'
      before(:all) { get '/register' }
    end

    context 'if signed in,' do
      include_context 'signed in'
      before do
        get '/register'
      end

      it_behaves_like 'redirect', '/'
    end
  end

  #
  # /users/:username
  #
  describe 'GET /users/:username' do
    context 'if signed in, ' do
      include_context 'signed in'
      before { get "/users/#{UN}" }
      it_behaves_like 'an emaki page'
    end
  end

  #
  # /users
  #
  describe 'POST /users' do
    context 'with email (@がない)' do
      before(:all) do
        flush_testdb!
        post '/users',
             username: UN,
             password: UN + 'password',
             name: 'テスト用ユーザー',
             email: 'test.user.email2testuser.com'
      end
      after(:all) { flush_testdb! }

      it_behaves_like 'redirect', '/register'
      it_behaves_like "does not create user #{UN}"
    end

    context 'with empty password' do
      before(:all) do
        flush_testdb!
        post '/users',
             username: UN,
             password: '',
             name: 'テスト用ユーザー',
             email: 'test.user.email@testuser.com'
      end
      after(:all) { flush_testdb! }

      it_behaves_like 'redirect', '/register'
      it_behaves_like "does not create user #{UN}"
    end
    context 'with password 51' do
      before(:all) do
        flush_testdb!
        post '/users',
             username: UN,
             password: 'p' * 51,
             name: 'テ' * 50,
             email: 'test.user.email@testuser.com'
      end
      after(:all) { flush_testdb! }

      it_behaves_like 'redirect', '/register'
      it_behaves_like "does not create user #{UN}"
    end
    context 'with name 51' do
      before(:all) do
        flush_testdb!
        post '/users',
             username: UN,
             password: UN + 'password',
             name: 'テ' * 51,
             email: 'test.user.email@testuser.com'
      end
      after(:all) { flush_testdb! }

      it_behaves_like 'redirect', '/register'
      it_behaves_like "does not create user #{UN}"
    end
    context 'with invalid username' do
      before(:all) do
        flush_testdb!
        post '/users',
             username: '-',
             password: UN + 'password',
             name: 'テスト用ユーザー',
             email: 'test.user.email@testuser.com'
      end
      after(:all) { flush_testdb! }

      it_behaves_like 'redirect', '/register'
      it_behaves_like "does not create user #{UN}"
    end

    # ユーザー登録正常系
    context 'with valid user informations' do
      before(:all) do
        flush_testdb!
        post '/users',
             username: UN,
             password: UN + 'password',
             name: 'テスト用ユーザー',
             email: 'test.user.email@testuser.com'
      end
      after(:all) { flush_testdb! }

      it_behaves_like 'redirect', '/'

      it 'creates new User' do
        expect(User.first(slug: UN)).not_to be nil
      end

      it 'sets parameters to new User' do
        expect(User.first(slug: UN).password).to eq(UN + 'password')
        expect(User.first(slug: UN).name).to eq 'テスト用ユーザー'
        expect(User.first(slug: UN).email).to eq 'test.user.email@testuser.com'
      end

      it 'auto signin' do
        expect(session[:user]).to eq UN
      end
    end
    context 'if signed in,' do
      include_context 'signed in'
      before do
        post '/users',
             username: UN,
             password: UN + 'password',
             name: 'テスト用ユーザー',
             email: 'test.user.email@testuser.com'
      end

      it_behaves_like 'redirect', '/'
    end

    # ID重複時
    context 'if already registered,' do
      include_context 'user created'
      before do
        post '/users',
             username: UN,
             password: 'another_password',
             name: 'IDが被っている人',
             email: 'another.user.email@testuser.com'
      end
      it_behaves_like 'redirect', '/register'

      context 'follow redirect,' do
        let(:oga_html) { Oga.parse_html(last_response.body) }
        before { follow_redirect! }

        it 'with slug dupl warning' do
          expect(oga_html).to desplay '#attention #slugDupl'
        end

        it 'without new user' do
          expect(User.count).to eq 1
        end
      end
    end
  end

  #
  # /signin
  #
  describe 'GET /signin' do
    it_behaves_like 'an emaki page'
    before(:all) { get '/signin' }

    context 'if signed in,' do
      include_context 'signed in'
      before do
        get '/signin'
      end

      it_behaves_like 'redirect', '/'
    end
  end

  describe 'POST /signin' do
    include_context 'user created',
                    slug: UN,
                    name: UN,
                    email: UN + '@test.com',
                    password: 'password'
    context 'with miss, ' do
      before do
        post '/signin',
             username_or_email: 'miss',
             password: 'password'
      end

      it 'empty session[:user]' do
        expect(session[:user]).to eq nil
      end
    end
    context 'with valid information,' do
      before do
        post '/signin',
             username_or_email: UN,
             password: 'password'
      end

      it 'sets userslug in session[:user]' do
        expect(session[:user]).to eq UN
      end
    end
    context 'if signed in,' do
      include_context 'signed in'
      before(:all) do
        post '/signin',
             username_or_email: UN,
             password: 'password'
      end

      it_behaves_like 'redirect', '/'
    end
  end

  describe 'GET /signout' do
    include_context 'user created',
                    slug: UN,
                    name: UN,
                    email: UN + '@test.com',
                    password: 'password'
    before do
      post '/signin',
           username_or_email: UN,
           password: 'password'
      get '/signout'
    end

    it 'reset session[:user]' do
      expect(session[:user]).to eq nil
    end
  end

  #
  #  /new
  #
  describe 'GET /new' do
    context 'if signed in, ' do
      include_context 'signed in'
      it_behaves_like 'an emaki page'
      let(:form) { 'form#newSlide' }
      let(:sninput) { 'input#slidename' }
      let(:slinput) { 'input#slide' }
      let(:title) { 'input#title' }
      let(:description) { 'textarea#description' }
      before { get '/new' }
      it { expect(oga_html).to desplay form }
      it { expect(oga_html).to desplay form, :action, '/slides' }
      it { expect(oga_html).to desplay form, :method, 'post' }
      it { expect(oga_html).to desplay form, :enctype, 'multipart/form-data' }
      it { expect(oga_html).to desplay sninput, :type, 'text' }
      it { expect(oga_html).to desplay sninput, :name, 'slidename' }
      it { expect(oga_html).to desplay slinput, :type, 'file' }
      it { expect(oga_html).to desplay slinput, :name, 'slide' }
      it { expect(oga_html).to desplay title, :type, 'text' }
      it { expect(oga_html).to desplay title, :name, 'title' }
      it { expect(oga_html).to desplay description, :name, 'description' }
      it { expect(oga_html).to desplay 'input[type="submit"]' }
    end

    context 'if signed out, ' do
      include_context 'signed out'
      before { get '/new' }
      it_behaves_like 'redirect', '/'
    end
  end

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

  #
  # /slides
  #
  describe 'POST /slides' do
    shared_examples "creates user #{UN}" do
      before do
        @u = User.first(slug: UN)
      end
      it('user exists') { expect(@u).not_to eq nil }
      it('user has name') { expect(@u.name).not_to eq nil }
    end

    shared_examples "creates slide #{SN}" do
      before do
        @s = Slide.first(user: User.first(slug: UN), slug: SN)
      end
      it('slide exists') { expect(@s).not_to eq nil }
      it('slide has title') { expect(@s.title).not_to eq nil }
      it('slide has description') { expect(@s.description).not_to eq nil }
    end

    context 'if slidename is invalid,' do
      include_context 'signed in', nil, :all
      include_context 'slide posted with', UN, '--'
      it_behaves_like 'redirect', '/new'
      it_behaves_like "does not create slide #{SN}"

      context 'follow redirect,' do
        let(:oga_html) { Oga.parse_html(last_response.body) }
        before { follow_redirect! }

        it 'with slug rules' do
          expect(oga_html).to desplay '#attention #slugRule'
        end
      end
    end

    context 'no file,' do
      include_context 'signed in', nil, :all
      include_context 'slide posted with', UN, SN, 'wrong_file'
      it_behaves_like 'redirect', '/new'
      it_behaves_like "does not create slide #{SN}"

      context 'follow redirect,' do
        let(:oga_html) { Oga.parse_html(last_response.body) }
        before { follow_redirect! }
        it 'with no file attention' do
          expect(oga_html).to desplay '#attention #noFile'
        end
      end
    end

    context 'with valid slide informations' do
      include_context 'signed in', nil, :all
      include_context 'slide posted with'
      it_behaves_like 'redirect', "/#{UN}/#{SN}"
      it_behaves_like "creates slide #{SN}"

      it "creates directory slides/#{UN}/#{SN}" do
        expect(FileTest.exist? slide_path).to be true
      end

      it 'creates png images in the directory' do
        expect(FileTest.exist? slide_path + '/0.png').to be true
        expect(FileTest.exist? slide_path + '/1.png').to be true
        expect(FileTest.exist? slide_path + '/2.png').to be true
      end

      it 'cleanup /tmp' do
        expect(Dir.entries(Binder.tmppath).join).to eq '...'
      end

    end

    context 'if signed out, ' do
      include_context 'signed out', :all
      include_context 'slide posted with'
      it_behaves_like 'redirect', '/'
      it_behaves_like "does not create slide #{SN}"
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
