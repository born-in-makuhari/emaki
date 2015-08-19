require File.expand_path '../../spec_helper.rb', __FILE__

# フィーチャースペック
#
# 画面とサーバーの機能を結合したスペック。
# 画面表示や画面操作のテスト。
#
# TODO: 今spec/emaki_spec.rbに書いているフィーチャースペックはココに移す

describe 'Top page', type: :feature do
  before do
    visit '/'
  end

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
  end
end

describe 'Register page', type: :feature do
  let(:form) { find('form#register') }
  before do
    visit '/register'
  end

  it 'links to Top' do
    click_link 'toTop'
    uri = URI.parse(current_url)
    expect(uri.path).to eq '/'
  end

  context 'if not signed in' do
    it { expect(page).to have_css 'form#register' }
    it do
      expect(form.native.attributes['method'].value).to eq 'post'
      expect(form.native.attributes['action'].value).to eq '/users'
    end
    it { expect(page).to have_css 'form#register input#username' }
    it { expect(page).to have_css 'form#register input#name' }
    it { expect(page).to have_css 'form#register input#email' }
    it { expect(page).to have_css 'form#register input#password' }
    it { expect(page).to have_css 'form#register input[type="submit"]' }
  end

  context 'if signed in' do
    it 'redirects to Top'
    it 'has attention "welcome"'
  end
end

describe 'Slide page', type: :feature do
  include_context 'slide posted with', true, true, true

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
