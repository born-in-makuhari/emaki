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
  let(:html) { Oga.parse_html(last_response.body) }

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
    before do
      get '/'
    end
    it { expect(html).to desplay 'a#toNew', 'href', '/new' }
  end

  #
  #  /new
  #
  describe 'GET /new' do
    it_behaves_like 'an emaki page'
    before :all do
      get '/new'
    end
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

  #
  # SLIDE PAGE
  # /username/slidename
  #
  describe 'GET /username/slidename' do
    it_behaves_like 'an emaki page'
    it_behaves_like 'a slide page'

    before do
      pdf_path = SPEC_ROOT + '/test.pdf'
      @d = { username: UN, slidename: SN,
        slide: Rack::Test::UploadedFile.new(pdf_path, 'application/pdf') }
      @path = Slide.makepath @d[:username], @d[:slidename]
      post '/slides', @d
      get '/testuser/testslide'
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

      describe 'html' do
      end
    end
  end

end
