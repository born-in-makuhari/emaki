require File.expand_path '../../spec_helper.rb', __FILE__

# slide関連のファイル操作を行うBinderクラスをテスト
describe 'Emaki::Binder' do

  before :all do
    @un_path = EMAKI_ROOT + "/slides/#{UN}"
    @sn_path = EMAKI_ROOT + "/slides/#{UN}/#{SN}"
  end

  after do
    FileUtils.rmdir(@sn_path)
    FileUtils.rmdir(@un_path)
  end

  # ===============================================================
  # Manipulate slides/ directory & files
  #
  # ---------------------------------------------------------------
  # safety
  #
  describe '.valid_slugs?' do
    shared_context '.valid_slug? returns' do |slugs|
      before do
        allow(Binder).to receive(:valid_slug?).and_return(*slugs)
      end
    end

    context 'when all ok' do
      include_context '.valid_slug? returns', [true, true, true]
      before do
        expect(Binder).to receive(:valid_slug?).exactly(3).times
      end
      it { expect(Binder.valid_slugs?('a', 'b', 'c')).to be true }
    end

    context 'when all NG' do
      include_context '.valid_slug? returns', [false, false, false]
      it { expect(Binder.valid_slugs?('a', 'b', 'c')).to be false }
    end

    context 'when one NG' do
      include_context '.valid_slug? returns', [true, true, false]
      it { expect(Binder.valid_slugs?('a', 'b', 'c')).to be false }
    end
  end

  describe '.valid_slug?' do
    it 'max 50' do
      expect(Binder.valid_slug?('A' * 50)).to be true
      expect(Binder.valid_slug?('A' * 51)).to be false
    end

    it 'min 1' do
      expect(Binder.valid_slug?('A' * 1)).to be true
      expect(Binder.valid_slug?('A' * 0)).to be false
    end

    it 'requires alphabet at the first' do
      expect(Binder.valid_slug?('a' * 1)).to be true
      expect(Binder.valid_slug?('-aaa' * 1)).to be false
      expect(Binder.valid_slug?('_aaa' * 1)).to be false
      expect(Binder.valid_slug?('_aaa' + ('a' * 20) + '_')).to be false
    end

    it 'requires alphabet at the last' do
      expect(Binder.valid_slug?('a' * 1)).to be true
      expect(Binder.valid_slug?('aaa-' * 1)).to be false
      expect(Binder.valid_slug?('aaa_' * 1)).to be false
      expect(Binder.valid_slug?('_' + ('a' * 20) + '_')).to be false
    end

    it 'allows A-Z, a-z, -, _ only' do
      expect(Binder.valid_slug?('A-a_z-Z' * 1)).to be true
      expect(Binder.valid_slug?('A=Z' * 1)).to be false
      expect(Binder.valid_slug?('にほんご' * 1)).to be false
    end
  end

  describe '.makepath' do
    it { expect(Binder.makepath(UN, SN)).to eq @sn_path }
  end

  describe '.exist?' do
    context "when #{@sn_path} exists," do
      before { Binder.mkdir(UN, SN) }
      it { expect(Binder.exist?(UN, SN)).to be true }
    end
    context "when #{@sn_path} does not exist," do
      it { expect(Binder.exist?(UN, SN)).to be false }
    end
  end

  shared_context 'pages exist' do |page_number|
    before :all do
      FileUtils.mkdir_p(@sn_path)
      @dummy_files = []
      @page_urls = []
      page_number.times do |i|
        dummy_file = @sn_path + "/#{i}_dummy.txt"
        FileUtils.touch(dummy_file)
        @dummy_files << dummy_file
        @page_urls << "/#{UN}/#{SN}/#{i}.png"
      end
    end

    after :all do
      @dummy_files.each do |file|
        FileUtils.remove(file)
      end
    end
  end

  describe '.page_urls' do
    include_context 'pages exist', 5
    it { expect(Binder.page_urls(UN, SN).length).to be 5 }
    it { expect(Binder.page_urls(UN, SN)).to eq @page_urls }
  end

  describe '.page_number' do
    context do
      include_context 'pages exist', 5
      it { expect(Binder.page_number(UN, SN)).to be 5 }
    end
    context 'if slide doesnot exist,' do
      it { expect(Binder.page_number(UN, SN)).to be 0 }
    end
  end

  # ---------------------------------------------------------------
  # invasive
  #
  describe '.mkdir' do
    before :all do
      Binder.mkdir(UN, SN)
    end

    it "(#{UN}, #{SN})  -> create ..../slides/#{UN}/#{SN}" do
      expect(FileTest.exist?(@un_path)).to be true
      expect(FileTest.exist?(@sn_path)).to be true
    end
  end

  describe '.rmdir' do
    before do
      FileUtils.mkdir_p(@sn_path)
      Binder.rmdir(UN, SN)
    end

    it "(#{UN}, #{SN}) -> remove ..../slides/#{UN}/#{SN}" do
      expect(FileTest.exist?(@sn_path)).to be false
    end

    it "'#{UN}' still exists" do
      expect(FileTest.exist?(@un_path)).to be true
    end
  end
  # ===============================================================
  # Manipulate tmp/ directory & files
  #
  # ---------------------------------------------------------------
  # invasive
  #
  describe 'Binder manipulates tmp/' do
    before do
      slide = {
        filename: 'test.pdf',
        tempfile:
          Rack::Test::UploadedFile.new(PDF_PATH, 'application/pdf')
      }
      @key = Binder.tmpsave slide
    end

    after { FileUtils.rm_rf(EMAKI_ROOT + '/tmp') }

    describe '.tmpsave' do
      it 'saves tmpfile' do
        expect(FileTest.exist?(EMAKI_ROOT + '/tmp/' + @key)).to be true
      end
    end

    describe '.tmpremove' do
      context 'with key' do
        before { @result = Binder.tmpremove(@key) }

        it 'removes tmpfile' do
          expect(FileTest.exist?(EMAKI_ROOT + '/tmp/' + @key)).to be false
        end

        it 'returns tmpfile fullpath list' do
          expect(@result).to eq [EMAKI_ROOT + '/tmp/' + @key]
        end
      end

      context 'without key' do
        before { @result = Binder.tmpremove('') }

        it 'returns nil' do
          expect(@result).to be nil
        end

        it 'doesnot remove tmpfile' do
          expect(FileTest.exist?(EMAKI_ROOT + '/tmp/' + @key)).to be true
        end
      end
    end
  end

  # ---------------------------------------------------------------
  # safety
  #
  describe '.tmppath' do
    it { expect(Binder.tmppath).to eq "#{EMAKI_ROOT}/tmp" }
  end
  describe '.tmp' do
    before do
      FileUtils.rm_rf(EMAKI_ROOT + '/tmp')
      Binder.tmp
    end
    it 'creates tmp/ directory' do
      expect(FileTest.exist?(EMAKI_ROOT + '/tmp')).to be true
    end
  end
  describe '.maketmpkey' do
    context 'when same key provided,' do
      it 'provides strings not duplicated each other (sample 10000)' do
        count = {}
        10_000.times.map do
          key = Binder.maketmpkey('duplicated.pdf')
          count[key] = true
        end
        expect(count.keys.length).to be 10_000
      end
    end
  end

  #
  # and more...
  #
end
