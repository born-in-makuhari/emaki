require File.expand_path '../spec_helper.rb', __FILE__

# slide関連のファイル操作を行うSlideクラスをテスト
describe 'Emaki::Slide' do

  # tips: allをつけると１回だけ実行する。
  #       デフォルトはeach(毎回)
  before :all do
    @un_path = File.expand_path('../..', __FILE__) + "/slides/#{UN}"
    @sn_path = File.expand_path('../..', __FILE__) + "/slides/#{UN}/#{SN}"
    puts "user  dir: #{@un_path}"
    puts "slide dir: #{@sn_path}"
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
        FileUtils.mkdir_p(@sn_path)
        Slide.rmdir(@un, @sn)
      end

      it "(#{UN}, #{SN}) -> remove ..../slides/#{UN}/#{SN}" do
        expect(FileTest.exist?(@sn_path)).to be false
      end

      it "'#{UN}' still exists" do
        expect(FileTest.exist?(@un_path)).to be true
      end
    end

    describe '.makepath' do
      it "(#{UN}, #{SN}) -> ..../slides/#{UN}/#{SN}"
    end
  end
end
