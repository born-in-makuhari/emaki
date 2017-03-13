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

# ====================================================================
#
# Top page
#

describe 'Top page', type: :feature do
  before { visit '/' }

  it 'links to Top' do
    click_link 'toTop'
    uri = URI.parse(current_url)
    expect(uri.path).to eq '/'
  end

  context 'if not signed in, ' do
    it 'links to Register' do
      click_link 'toRegister'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/register'
    end
    it 'links to SignIn' do
      click_link 'toSignIn'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/signin'
    end
    it { expect(page).not_to have_css 'a#toNew' }
    it 'does not display userinfo' do
      expect(page).not_to have_css '#userinfo'
    end
    it 'does not display toSignOut' do
      expect(page).not_to have_css 'a#toSignOut'
    end
  end

  context 'if signed in, ' do
    include_context 'user created',
                    slug: 'for-signin',
                    name: 'ログインテスト用',
                    email: 'for.signin@test.com',
                    password: 'for-signin'
    before do
      visit '/signin'
      fill_in 'usernameOrEmail', with: 'for-signin'
      fill_in 'password', with: 'for-signin'
      find('form#signin input[type=submit]').click
      visit '/'
    end
    it { expect(page).not_to have_css 'a#toRegister' }
    it { expect(page).not_to have_css 'a#toSignIn' }
    it 'links to New' do
      click_link 'toNew'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/new'
    end
    it 'links to SignOut' do
      click_link 'toSignOut'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/'
      expect(page).not_to have_css '#userinfo'
    end
  end
end

# ====================================================================
#
# Register page
#

describe 'Register page', type: :feature do
  let(:form) { find 'form#register' }
  before { visit '/register' }

  it 'links to Top' do
    click_link 'toTop'
    uri = URI.parse(current_url)
    expect(uri.path).to eq '/'
  end
  it 'links to Register' do
    click_link 'toRegister'
    uri = URI.parse(current_url)
    expect(uri.path).to eq '/register'
  end
  it 'links to SignIn' do
    click_link 'toSignIn'
    uri = URI.parse(current_url)
    expect(uri.path).to eq '/signin'
  end

  context 'if not signed in' do
    it do
      expect('form#register').to have_attr 'method', 'post'
      expect('form#register').to have_attr 'action', '/users'
    end
    it { expect('#register input#username').to have_attr 'type', 'text' }
    it { expect('#register input#username').to have_attr 'name', 'username' }
    it { expect('#register input#name').to have_attr 'type', 'text' }
    it { expect('#register input#name').to have_attr 'name', 'name' }
    it { expect('#register input#email').to have_attr 'type', 'text' }
    it { expect('#register input#email').to have_attr 'name', 'email' }
    it { expect('#register input#password').to have_attr 'type', 'password' }
    it { expect('#register input#password').to have_attr 'name', 'password' }
    it { expect(page).to have_css 'form#register input[type="submit"]' }

    context 'when submit valid informations,' do
      before do
        fill_in 'username', with: 'emeria'
        fill_in 'name', with: '最初のユーザー'
        fill_in 'password', with: 'iona'
        fill_in 'email', with: 'shield-of-emeria@mtg.com'
        find('form#register input[type=submit]').click
      end
      it 'redirects to Top' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/'
      end
      it 'displays #welcomeUser' do
        expect(page).to have_css '#welcomeUser'
      end
      after { User.first(slug: 'emeria').destroy }
    end

    it 'does not display userinfo' do
      expect(page).not_to have_css '#userinfo'
    end
  end

end

# ====================================================================
#
# SignIn page
#

describe 'SignIn page', type: :feature do
  let(:form) { find 'form#signin' }
  before { visit '/signin' }
  include_context 'user created',
                  slug: 'for-signin',
                  name: 'ログインテスト用',
                  email: 'for.signin@test.com',
                  password: 'for-signin'

  context 'if not signed in' do
    it 'links to Top' do
      click_link 'toTop'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/'
    end
    it 'links to Register' do
      click_link 'toRegister'
      uri = URI.parse(current_url)
      expect(uri.path).to eq '/register'
    end
    it do
      expect('form#signin').to have_attr 'method', 'post'
      expect('form#signin').to have_attr 'action', '/signin'
    end
    it do
      expect('form#signin input#usernameOrEmail')
        .to have_attr 'name', 'username_or_email'
    end
    it do
      expect('form#signin input#password').to have_attr 'name', 'password'
      expect('form#signin input#password').to have_attr 'type', 'password'
    end
    it { expect(page).to have_css 'form#signin input[type="submit"]' }

    context 'when miss, ' do
      before do
        fill_in 'usernameOrEmail', with: 'eeeee'
        fill_in 'password', with: 'ppppp'
        find('form#signin input[type=submit]').click
      end

      it 'redirects to SignIn' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/signin'
      end

      it 'keeps values.' do
        expect(find('#usernameOrEmail').value).to eq 'eeeee'
        expect(find('#password').value).to eq 'ppppp'
      end
    end

    context 'when submit email/password' do
      before do
        fill_in 'usernameOrEmail', with: 'for.signin@test.com'
        fill_in 'password', with: 'for-signin'
        find('form#signin input[type=submit]').click
      end

      it 'redirects to Top' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/'
      end

      it 'displays userinfo' do
        expect(page).to have_css '#userinfo'
      end
    end

    context 'when submit username/password' do
      before do
        fill_in 'usernameOrEmail', with: 'for-signin'
        fill_in 'password', with: 'for-signin'
        find('form#signin input[type=submit]').click
      end

      it 'redirects to Top' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/'
      end

      it 'displays userinfo' do
        expect(page).to have_css '#userinfo'
      end
    end
  end

end

# ====================================================================
#
# User page
#

describe 'User page', type: :feature do
  context 'if signed in, ' do
    include_context 'signed in', nil, :all
    before { visit "/users/#{UN}" }

    it 'displays user page' do
      expect(uri.path).to eq "/users/#{UN}"
    end
  end
end

# ====================================================================
#
# SignOut page
#

describe 'SignOut page', type: :feature do
  let(:form) { find 'form#signin' }
  before { visit '/signin' }
  include_context 'user created',
                  slug: 'for-signin',
                  name: 'ログインテスト用',
                  email: 'for.signin@test.com',
                  password: 'for-signin'

  context 'if signed in, ' do
    before do
      fill_in 'usernameOrEmail', with: 'for.signin@test.com'
      fill_in 'password', with: 'for-signin'
      find('form#signin input[type=submit]').click
    end

    context 'when sign out, ' do
      before { visit '/signout' }

      it 'redirects to Top' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq '/'
      end

      it 'displays #goodbyeUser' do
        expect(page).to have_css '#goodbyeUser'
      end
    end
  end
end

# ====================================================================
#
# New page
#
describe 'New page', type: :feature do
  include_context 'user created',
                  slug: 'for-signin',
                  name: 'ログインテスト用',
                  email: 'for.signin@test.com',
                  password: 'for-signin'

  context 'when miss values, ' do
    before do
      visit '/signin'
      fill_in 'usernameOrEmail', with: 'for-signin'
      fill_in 'password', with: 'for-signin'
      find('form#signin input[type=submit]').click

      visit '/new'
      fill_in 'slidename', with: '-----'
      fill_in 'title', with: 'ttttt'
      fill_in 'description', with: 'ddddd'

      find('input[type=submit]').click
    end

    it 'keeps values.' do
      expect(find('#slidename').value).to eq '-----'
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
  include_context 'slide posted with', true, true, true

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
