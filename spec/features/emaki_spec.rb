require File.expand_path '../../spec_helper.rb', __FILE__

describe 'Common page', type: :feature do
  it 'links to top' do
    visit '/'
    click_link 'toTop'
    uri = URI.parse(current_url)
    expect(uri.path).to eq '/'
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
