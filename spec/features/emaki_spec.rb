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

  before do
    visit "/#{UN}/#{SN}"
  end

  describe 'has Page Indicator' do
    let(:indicator) { 'progress#pageIndicator' }
    it { expect(page).to have_css indicator }
    it 'max=2' do
      expect(find(indicator)[:max]).to eq "2"
    end
    it 'displays 0' do
      expect(find(indicator).value).to eq "0"
    end

    context 'when #next clicked, ' do

      it 'displays 1'
    end
  end
end
