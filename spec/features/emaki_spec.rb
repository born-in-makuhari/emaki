require File.expand_path '../../spec_helper.rb', __FILE__
#
#              Feature Specs
#
# 画面とサーバーの機能を結合したスペック。
# 画面表示や画面操作のテスト。
#
# TODO: 今spec/emaki_spec.rbに書いているフィーチャースペックはココに移す

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
  end

  context 'if signed in' do
    it
  end
end

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
    it { expect('form#register input#username').to have_attr 'type', 'text' }
    it { expect('form#register input#username').to have_attr 'name', 'username' }
    it { expect('form#register input#name').to have_attr 'name', 'name' }
    it { expect(page).to have_css 'form#register input#email' }
    it { expect(page).to have_css 'form#register input#password' }
    it { expect(page).to have_css 'form#register input[type="submit"]' }
  end

  context 'if signed in' do
    it 'redirects to Top'
    it 'has attention "welcome"'
  end
end

#
# SignIn page
#

describe 'SignIn page', type: :feature do
  let(:form) { find 'form#signin' }
  before { visit '/signin' }

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
    it { expect(page).to have_css 'form#signin' }
    it do
      expect(form.native.attributes['method'].value).to eq 'post'
      expect(form.native.attributes['action'].value).to eq '/signin'
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
  end

  context 'if signed in' do
    it
  end
end

#
# Slide page
#

describe 'Slide page', type: :feature do
  include_context 'slide posted with', true, true, true

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
  end

  context 'if signed in' do
    it
  end

  before :each do
    visit "/#{UN}/#{SN}"
    @indicator = find 'progress#pageIndicator'
    @next_button = find 'button#next'
  end

  describe 'has Page Indicator' do
    it 'max=2' do
      expect(@indicator[:max]).to eq '2'
    end
    it 'displays 0' do
      expect(@indicator.value).to eq '0'
    end
  end
end
