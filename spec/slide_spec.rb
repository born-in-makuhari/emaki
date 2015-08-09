require File.expand_path '../spec_helper.rb', __FILE__

# slide関連のファイル操作を行うSlideクラスをテスト
describe 'Emaki::Slide' do

  context "when (#{UN}, #{SN}) given" do
    before do
      @sn_path = File.expand_path('../..', __FILE__) + "/slides/#{UN}/#{SN}"
      @un_path = File.expand_path('../..', __FILE__) + "/slides/#{UN}/#{SN}"
      puts @sn_path
      puts @un_path
      FileUtils.rmdir(@sn_path)
      FileUtils.rmdir(@un_path)
      Slide.mkdir(UN, SN)
    end

    after do
      FileUtils.rmdir(@sn_path)
      FileUtils.rmdir(@un_path)
    end
    describe '.mkdir' do
      it "(#{UN}, #{SN})  -> create ..../slides/#{UN}/#{SN}" do
        expect(FileTest.exist?(@un_path)).to be true
        expect(FileTest.exist?(@sn_path)).to be true
      end
    end

    describe '.rmdir' do
      # 注意：ユーザーディレクトリは削除しない
      it "(#{UN}, #{SN}) -> remove ..../slides/#{UN}/#{SN}"
    end

    describe '.makepath' do
      it "(#{UN}, #{SN}) -> ..../slides/#{UN}/#{SN}"
    end
  end
end
