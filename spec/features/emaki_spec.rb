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
  describe 'has Page Indicator' do
    it { expect(page).to have_css 'progress#pageIndicator' }
    it 'displays now page (default page 0)'
    it 'displays now page (default page 0)'
  end
end
