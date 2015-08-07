require File.expand_path '../spec_helper.rb', __FILE__

describe 'Emaki' do
  describe 'when GET /' do
    before { get '/' }
    it 'returns 200' do
      expect(last_response).to be_ok
    end
  end
end
