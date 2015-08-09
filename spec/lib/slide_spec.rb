require File.expand_path '../../spec_helper.rb', __FILE__

# slide関連のファイル操作を行うSlideクラスをテスト
describe 'Emaki::Slide' do

  # tips: allをつけると１回だけ実行する。
  #       デフォルトはeach(毎回)
  before :all do
    @un_path = EMAKI_ROOT + "/slides/#{UN}"
    @sn_path = EMAKI_ROOT + "/slides/#{UN}/#{SN}"
    puts "user  dir: #{@un_path}"
    puts "slide dir: #{@sn_path}"
  end

  context "when (#{UN}, #{SN}) given" do
    before do
      @un = UN
      @sn = SN
    end

    after do
      FileUtils.rmdir(@sn_path)
      FileUtils.rmdir(@un_path)
    end

    describe '.makepath' do
      it { expect(Slide.makepath(@un, @sn)).to eq @sn_path }
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

    describe '.exist?' do
      context "when #{@sn_path} exists," do
        before { Slide.mkdir(@un, @sn) }
        it { expect(Slide.exist?(@un, @sn)).to be true }
      end
      context "when #{@sn_path} does not exist," do
        it { expect(Slide.exist?(@un, @sn)).to be false }
      end
    end
    #
    # control tmp/
    #
    describe 'Slide manipulates tmp/' do
      describe '.tmpsave' do
        context 'with file' do
          it 'saves tmpfile'
          it 'returns tmpfile name'
        end
        context 'without file' do
          it 'returns nil'
        end
      end
      describe '.tmpremove' do
        context 'with key' do
          it 'removes tmpfile'
          it 'returns tmpfile name'
        end
        context 'without key' do
          it 'returns nil'
        end
      end
      describe '.tmppath' do
        it "returns #{EMAKI_ROOT}/tmp"
      end
      describe '.tmp' do
        it 'creates tmp/ directory'
      end
      describe '.maketmpkey' do
        it 'returns random+time+filename string'
        it 'provides strings not duplicated each other (sample 10000)'
      end
    end
  end
end
