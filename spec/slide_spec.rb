require File.expand_path '../spec_helper.rb', __FILE__

# slide関連のファイル操作を行うSlideクラスをテスト
describe 'Emaki::Slide' do
  before do
    @un_path = File.expand_path('../..', __FILE__) + "/slides/#{UN}/#{SN}"
    @sn_path = File.expand_path('../..', __FILE__) + "/slides/#{UN}/#{SN}"
  end

  context "when (#{UN}, #{SN}) given" do
    before do
      @un = UN
      @sn = SN
    end

    describe '.mkdir' do
      before do
        FileUtils.rmdir(@sn_path)
        FileUtils.rmdir(@un_path)
        Slide.mkdir(@un, @sn)
      end

      after do
        FileUtils.rmdir(@sn_path)
        FileUtils.rmdir(@un_path)
      end

      it "(#{UN}, #{SN})  -> create ..../slides/#{UN}/#{SN}" do
        expect(FileTest.exist?(@un_path)).to be true
        expect(FileTest.exist?(@sn_path)).to be true
      end
    end

    describe '.rmdir' do
      before do
        FileUtils.rmdir(@sn_path)
        FileUtils.rmdir(@un_path)
        Slide.mkdir(@un, @sn)
      end

      after do
        FileUtils.rmdir(@sn_path)
        FileUtils.rmdir(@un_path)
      end
      # 注意：ユーザーディレクトリは削除しない
      it "(#{UN}, #{SN}) -> remove ..../slides/#{UN}/#{SN}" do
      end
    end

    describe '.makepath' do
      it "(#{UN}, #{SN}) -> ..../slides/#{UN}/#{SN}"
    end
  end
end
