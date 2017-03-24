require File.expand_path '../../spec_helper.rb', __FILE__
#
#              Feature Specs
#
# 画面とサーバーの機能を結合したスペック。
# 画面表示や画面操作のテスト。
#
# TODO: 今spec/emaki_spec.rbに書いているフィーチャースペックはココに移す

# ====================================================================
# カスタムマッチャー
# have_attr(key, value)
#
# たとえばこういうのにマッチする
#     <div id="hoge" >
RSpec::Matchers.define :have_attr do |key, value|
  match do |actual|
    find(actual).native.attributes[key].value == value
  end
end

shared_context 'ログイン状態の場合' do
  include_context 'user created'
  before do
    visit '/signin'
    fill_in 'usernameOrEmail', with: UN
    fill_in 'password', with: 'password'
    find('form#signin input[type=submit]').click
  end
end

shared_context 'スライド登録済み' do
  before do
    visit '/new'
    fill_in 'slidename', with: SN
    fill_in 'title', with: STITLE
    fill_in 'description', with: 'タイトルの説明はどんな形式でもいい'
    find('input#slide.hidden', visible: false).set PDF_PATH
    find('form#newSlide input[type="submit"]').click
  end
  after do
    Slide.first(slug: SN).destroy if Slide.first(slug: SN)
    FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
    FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
  end
end

shared_examples_for 'ゲスト用ページ' do
  it '左上の「emaki」をクリックすると、トップページに移動する' do
    click_link 'toTop'
    uri = URI.parse(current_url)
    expect(uri.path).to eq '/'
  end

  context 'ログインしていない場合' do
    it '「Register」をクリックすると、ユーザー登録ページへ飛ぶ' do
      click_link 'toRegister'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/register'
    end
    it 'ログインのロゴをクリックすると、ログインページへ飛ぶ' do
      click_link 'toSignIn'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/signin'
    end
    it 'スライド登録ページへのリンクを表示しない' do
      expect(page).not_to have_css 'a#toNew'
    end
    it 'ユーザーページへのリンクを表示しない' do
      expect(page).not_to have_css '#userinfo'
    end
    it 'ログアウトのリンクを表示しない' do
      expect(page).not_to have_css 'a#toSignOut'
    end
  end
end

shared_examples_for 'ユーザー用ページ' do
  context 'ユーザー作成済みで、ログイン状態の場合' do
    include_context 'ログイン状態の場合'

    it 'スライド登録ページへのリンクを表示する' do
      expect(page).not_to have_css 'a#toRegister'
    end
    it 'ログインのリンクを表示しない' do
      expect(page).not_to have_css 'a#toSignIn'
    end
    it 'スライド登録ページへのリンクを表示する' do
      click_link 'toNew'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/new'
    end
    it 'ログアウトのリンクをクリックすると、ログアウトする' do
      click_link 'toSignOut'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/'
      expect(page).not_to have_css '#userinfo'
    end
    it 'マイページへのリンクを表示する' do
      click_link 'toUser'
      uri = URI.parse(current_url)
      expect(uri.path).to eq "/users/#{UN}"
    end
  end
end

# ====================================================================
#
# トップページ
# Top
#

describe 'トップページ', type: :feature, page: :top do
  before { visit '/' }

  it_behaves_like 'ゲスト用ページ'
  it_behaves_like 'ユーザー用ページ'
end

# ====================================================================
#
# ユーザー登録ページ
# Register
#

describe 'ユーザー登録ページ', type: :feature, page: :register do
  before { visit '/register' }

  context 'ログインしていない場合、' do
    it_behaves_like 'ゲスト用ページ'

    it 'フォームを表示する' do
      expect(page).to have_css 'form#register[method="post"]'
      expect(page).to have_css 'form#register[action="/users"]'
      expect(page).to have_css '#register input#username[type="text"]'
      expect(page).to have_css '#register input#username[name="username"]'
      expect(page).to have_css '#register input#name[type="text"]'
      expect(page).to have_css '#register input#name[name="name"]'
      expect(page).to have_css '#register input#email[type="text"]'
      expect(page).to have_css '#register input#email[name="email"]'
      expect(page).to have_css '#register input#password[type="password"]'
      expect(page).to have_css '#register input#password[name="password"]'
      expect(page).to have_css 'form#register input[type="submit"]'
    end

    context '正しい情報を入力して、送信ボタンをクリックした場合' do
      before do
        fill_in 'username', with: 'emeria'
        fill_in 'name', with: '最初のユーザー'
        fill_in 'password', with: 'iona'
        fill_in 'email', with: 'shield-of-emeria@mtg.com'
        find('form#register input[type=submit]').click
      end
      after do
        User.first(slug: 'emeria').destroy
      end
      it 'トップページへ飛ぶ' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/'
      end
      it '「ようこそ、***」と表示する' do
        expect(page).to have_content 'ようこそ、最初のユーザー'
      end
      it 'ユーザーが作成されている' do
        user = User.first(slug: 'emeria')
        expect(user.name).to eq '最初のユーザー'
        expect(user.password).to eq 'iona'
        expect(user.email).to eq 'shield-of-emeria@mtg.com'
      end
    end

    context 'emailに「@」をいれず、送信ボタンをクリックした場合' do
      before do
        fill_in 'username', with: 'gooduser'
        fill_in 'name', with: '素敵なユーザー'
        fill_in 'password', with: 'goodpassword'
        fill_in 'email', with: 'gooduseremail.com'
        find('form#register input[type=submit]').click
      end
      it 'ユーザー登録ページにリダイレクトする' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/register'
      end
      it 'ユーザーが作成されていない' do
        expect(User.exists?('gooduser')).to be false
      end
    end

    context 'パスワードが空欄のまま、送信ボタンをクリックした場合' do
      before do
        fill_in 'username', with: 'gooduser'
        fill_in 'name', with: '素敵なユーザー'
        fill_in 'password', with: ''
        fill_in 'email', with: 'gooduser@email.com'
        find('form#register input[type=submit]').click
      end
      it 'ユーザー登録ページにリダイレクトする' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/register'
      end
      it 'ユーザーが作成されていない' do
        expect(User.exists?('gooduser')).to be false
      end
    end

    context 'パスワードが51文字で、送信ボタンをクリックした場合' do
      before do
        fill_in 'username', with: 'gooduser'
        fill_in 'name', with: '素敵なユーザー'
        fill_in 'password', with: 'p' * 51
        fill_in 'email', with: 'gooduser@email.com'
        find('form#register input[type=submit]').click
      end
      it 'ユーザー登録ページにリダイレクトする' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/register'
      end
      it 'ユーザーが作成されていない' do
        expect(User.exists?('gooduser')).to be false
      end
    end

    context '名前が51文字で、送信ボタンをクリックした場合' do
      before do
        fill_in 'username', with: 'gooduser'
        fill_in 'name', with: 'ユ' * 51
        fill_in 'password', with: 'goodpassword'
        fill_in 'email', with: 'gooduser@email.com'
        find('form#register input[type=submit]').click
      end
      it 'ユーザー登録ページにリダイレクトする' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/register'
      end
      it 'ユーザーが作成されていない' do
        expect(User.exists?('gooduser')).to be false
      end
    end

    context 'ユーザーIDが「-」で始まる場合' do
      before do
        fill_in 'username', with: '-gooduser'
        fill_in 'name', with: '素敵なユーザー'
        fill_in 'password', with: 'goodpassword'
        fill_in 'email', with: 'gooduser@email.com'
        find('form#register input[type=submit]').click
      end
      it 'ユーザー登録ページにリダイレクトする' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/register'
      end
      it 'ユーザーが作成されていない' do
        expect(User.exists?('gooduser')).to be false
      end
    end

    context 'ユーザーIDが重複している場合' do
      include_context 'user created'
      before do
        fill_in 'username', with: UN
        fill_in 'name', with: '素敵なユーザー'
        fill_in 'password', with: 'goodpassword'
        fill_in 'email', with: 'gooduser@email.com'
        find('form#register input[type=submit]').click
      end
      it 'ユーザー登録ページにリダイレクトする' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/register'
      end
      it 'ユーザーが作成されていない' do
        expect(User.count).to eq 1
      end
    end
  end

  context 'ログイン状態の場合' do
    include_context 'ログイン状態の場合'
    it 'トップページへリダイレクトする' do
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/'
    end
  end

end

# ====================================================================
# ログインページ
# SignIn
#

describe 'ログインページ', type: :feature, page: :signin do
  let(:form) { find 'form#signin' }
  before { visit '/signin' }
  include_context 'user created'

  context 'ログイン状態の場合' do
    include_context 'ログイン状態の場合'
    it 'トップページへリダイレクトする' do
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/'
    end
  end

  context 'ログインしていない場合' do
    it_behaves_like 'ゲスト用ページ'

    it 'ログインフォームを表示する' do
      expect(page).to have_css 'form#signin[method="post"]'
      expect(page).to have_css 'form#signin[action="/signin"]'
      expect(page).to have_css(
        'form#signin input#usernameOrEmail[name="username_or_email"]'
      )
      expect(page).to have_css(
        'form#signin input#usernameOrEmail[type="text"]'
      )
      expect(page).to have_css(
        'form#signin input#password[name="password"]'
      )
      expect(page).to have_css(
        'form#signin input#password[type="password"]'
      )
      expect(page).to have_css 'form#signin input[type="submit"]'
    end

    context '誤った情報を入力した場合' do
      before do
        fill_in 'usernameOrEmail', with: 'eeeee'
        fill_in 'password', with: 'ppppp'
        find('form#signin input[type=submit]').click
      end

      it 'ログインページにリダイレクト' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/signin'
      end

      it '入力値は保持する' do
        expect(find('#usernameOrEmail').value).to eq 'eeeee'
        expect(find('#password').value).to eq 'ppppp'
      end
    end

    context '正しい情報を入力した場合(ユーザーID)' do
      before do
        fill_in 'usernameOrEmail', with: UN
        fill_in 'password', with: 'password'
        find('form#signin input[type=submit]').click
      end

      it 'トップページにリダイレクト' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/'
      end

      it 'ログイン状態である' do
        expect(page).to have_css '#userinfo'
      end

      context 'ログアウトをクリックした場合' do
        before do
          find('#toSignOut').click
        end
        it 'トップページにリダイレクト' do
          uri = URI.parse(current_url)
          expect(uri.path).to eq '/'
        end
        it '「ログアウトしました」と表示する' do
          expect(page).to have_content 'ログアウトしました'
        end
      end
    end

    context '正しい情報を入力した場合(メールアドレス)' do
      before do
        fill_in 'usernameOrEmail', with: UN + '@test.com'
        fill_in 'password', with: 'password'
        find('form#signin input[type=submit]').click
      end

      it 'トップページにリダイレクト' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/'
      end

      it 'ログイン状態である' do
        expect(page).to have_css '#userinfo'
      end
    end
  end

end

# ====================================================================
# マイページ
# User
#

describe 'マイページ', type: :feature, page: :user do
  include_context 'user created'
  include_context 'user created', {
    slug: 'another',
    name: 'ログインテスト用',
    email: 'for.signin@test.com',
    password: 'for-signin'
  }

  it_behaves_like 'ユーザー用ページ'

  context 'ログインしていない状態で、' do
    context '自分のページにアクセスした場合' do
      before { visit "/users/#{UN}" }

      it '「ログインが必要です」と警告され、' do
        expect(page).to have_content 'ログインが必要です'
      end
      it 'トップページへ移動する' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq "/"
      end
    end
    context '他人のページにアクセスした場合' do
      before { visit "/users/#{UN}" }

      it '「ログインが必要です」と警告され、' do
        expect(page).to have_content 'ログインが必要です'
      end
      it 'トップページへ移動する' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq "/"
      end
    end
  end

  context 'ログイン状態で、' do
    include_context 'ログイン状態の場合'
    context '他人のページにアクセスした場合' do
      before { visit "/users/another" }

      it '「ログインが必要です」と警告され、' do
        expect(page).to have_content 'ログインが必要です'
      end
      it 'トップページへ移動する' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq "/"
      end
    end

    context '自分のページにアクセスした場合' do
      before { visit "/users/#{UN}" }

      it 'マイページを表示する' do
        uri = URI.parse(current_url)
        expect(page).to have_content 'マイページ'
        expect(uri.path).to eq "/users/#{UN}"
      end
    end
  end

  context 'スライド一覧機能について' do
    context 'スライドがある状態でマイページにアクセスした時' do
      include_context 'ログイン状態の場合'
      include_context 'スライド登録済み'
      before { visit "/users/#{UN}" }

      it "そのユーザーのスライドを表示する" do
        expect(page).to have_content STITLE
      end

      context "スライド名をクリックした場合" do
        before { click_on 'タイトルの表示名' }
        it 'スライドページに遷移する' do
          uri = URI.parse(current_url)
          expect(uri.path).to eq "/#{UN}/#{SN}"
        end
      end
    end

    context 'スライドがない状態でマイページにアクセスした時' do
      include_context 'ログイン状態の場合'
      before { visit "/users/#{UN}" }

      it "「まだスライドがありません」と表示される" do
        expect(page).to have_content 'まだスライドがありません'
      end

      it "「新しいスライドを作成」というボタンが表示される" do
        expect(page).to have_content '新しいスライドを作成'
      end

      it "「新しいスライドを作成」をクリックするとスライド作成ページに飛ぶ" do
        click_on '新しいスライドを作成'
        uri = URI.parse(current_url)
        expect(uri.path).to eq "/new"
      end
    end
  end

  context 'スライド削除機能について' do
    context 'ログインして、' do
      include_context 'ログイン状態の場合'
      context 'スライドがある状態でマイページにアクセスした時' do
        include_context 'スライド登録済み'
        before { visit "/users/#{UN}" }

        context 'スライド横の「x」ボタンをクリックした場合' do
          before { find("#confirm-delete-#{UN}-#{SN}").click }

          it '「警告」と表示する' do
            expect(page).to have_content '警告'
          end
          it '「スライド「xxx」を削除しますか？」と表示する' do
            message = "スライド「#{STITLE}」を削除しますか？"
            expect(page).to have_content message
          end

          context 'さらに「削除」をクリックした場合' do
            before { click_on '削除' }

            it 'スライドが削除されている' do
              expect(Slide.count).to be 0
              expect(Binder.exist?(UN, SN)).to be false
            end

            it "「スライド「xxx」を削除しました」と表示される" do
              message = "スライド「#{STITLE}」を削除しました"
              expect(page).to have_content message
            end

            it 'マイページを表示する' do
              uri = URI.parse(current_url)
              expect(page).to have_content 'マイページ'
              expect(uri.path).to eq "/users/#{UN}"
            end
          end
        end
      end
    end
  end

end

# ====================================================================
# スライド登録ページ
# New
#
describe 'スライド登録ページ', type: :feature do
  include_context 'ログイン状態の場合'
  before { visit '/new' }

  context '正しい情報を入力して、送信した場合' do
    before do
      fill_in 'slidename', with: SN
      fill_in 'title', with: STITLE
      fill_in 'description', with: 'ddddd'
      attach_file 'slide', PDF_PATH
      find('input[type=submit]').click
    end
    after do
      Slide.first(slug: SN).destroy if Slide.first(slug: SN)
      FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}/#{SN}")
      FileUtils.rm_rf(EMAKI_ROOT + "/slides/#{UN}")
    end

    it 'スライドページにリダイレクトする' do
      uri = URI.parse(current_url)
      expect(uri.path).to eq "/#{UN}/#{SN}"
    end

    it 'スライドが登録されている' do
      slide = Slide.first(slug: SN)
      expect(slide.title).to eq STITLE
      expect(slide.description).to eq 'ddddd'
    end

    it 'PNG画像が作成されている' do
      slide_path = Binder.makepath(UN, SN)
      expect(FileTest.exist? slide_path + '/0.png').to be true
      expect(FileTest.exist? slide_path + '/1.png').to be true
      expect(FileTest.exist? slide_path + '/2.png').to be true
    end

    it '一時ファイル /tmp が空になっている' do
      expect(Dir.entries(Binder.tmppath).join).to eq '...'
    end
  end

  context '「-」で始まるスライドIDの場合' do
    before do
      fill_in 'slidename', with: '-slidename'
      fill_in 'title', with: 'ttttt'
      fill_in 'description', with: 'ddddd'
      attach_file 'slide', PDF_PATH
      find('input[type=submit]').click
    end

    it 'スライド登録ページにリダイレクトする' do
      uri = URI.parse(current_url)
      expect(uri.path).to eq "/new"
    end

    it '入力値を保持する' do
      expect(find('#slidename').value).to eq '-slidename'
      expect(find('#title').value).to eq 'ttttt'
      expect(find('#description').value).to eq 'ddddd'
    end
  end
end

# ====================================================================
#
# Slide page
#

describe 'Slide page', { type: :feature, js: true } do
  include_context 'signed in', nil, :all
  include_context 'slide posted with'

  before :each do
    visit "/#{UN}/#{SN}"
    @indicator = find 'progress#pageIndicator'
    @next_button = find 'button#next'
    @now_number = find '#nowNumber'
  end

  describe 'has Page Indicator' do
    it 'max=2' do
      expect(@indicator[:max]).to eq '2'
    end
    it 'displays 0' do
      expect(@indicator.value).to eq '0'
    end
  end

  describe 'if you click next button once,' do
    it 'Page Number is 2' do
      @next_button.click
      expect(@now_number.text).to eq '2'
    end
  end

  describe 'if you click next button twice,' do
    it 'Page Number is 3' do
      @next_button.click
      @next_button.click
      expect(@now_number.text).to eq '3'
    end
  end

  describe 'if you click next button 3 times,' do
    it 'Page Number is 3 (max)' do
      @next_button.click
      @next_button.click
      @next_button.click
      expect(@now_number.text).to eq '3'
    end
  end
end
