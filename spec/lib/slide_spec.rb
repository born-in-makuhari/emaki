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

    # ===============================================================
    # Manipulate slides/ directory & files
    #
    # ---------------------------------------------------------------
    # safety
    #
    describe '.makepath' do
      it { expect(Slide.makepath(@un, @sn)).to eq @sn_path }
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

    context 'if pages exist,' do
      before :all do
        FileUtils.mkdir_p(@sn_path)
        @dummy_files = []
        @page_urls = []
        @page_number = 5
        @page_number.times do |i|
          dummy_file = @sn_path + "/#{i}_dummy.txt"
          FileUtils.touch(dummy_file)
          @dummy_files << dummy_file
          @page_urls << "/#{@un}/#{@sn}/#{i}.png"
        end
      end

      after :all do
        @dummy_files.each do |file|
          FileUtils.remove(file)
        end
      end

      describe '.page_number' do
        it { expect(Slide.page_number(@un, @sn)).to be @page_number }
      end

      describe '.page_urls' do
        it { expect(Slide.page_urls(@un, @sn).length).to be @page_number }
        it { expect(Slide.page_urls(@un, @sn)).to eq @page_urls }
      end
    end

    context 'if slide doesnot exist,' do
      describe '.page_number' do
        it { expect(Slide.page_number(@un, @sn)).to be 0 }
      end
    end

    # ---------------------------------------------------------------
    # invasive
    #
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
    # ===============================================================
    # Manipulate tmp/ directory & files
    #
    # ---------------------------------------------------------------
    # invasive
    #
    describe 'Slide manipulates tmp/' do
      describe 'save & remove' do
        context 'with file' do
          before do
            pdf_path = SPEC_ROOT + '/test.pdf'
            slide = {
              filename: 'test.pdf',
              tempfile:
                Rack::Test::UploadedFile.new(pdf_path, 'application/pdf')
            }
            @key = Slide.tmpsave slide
          end

          after { FileUtils.rm_rf(EMAKI_ROOT + '/tmp') }

          describe '.tmpsave' do
            it 'saves tmpfile' do
              expect(FileTest.exist?(EMAKI_ROOT + '/tmp/' + @key)).to be true
            end
          end
          describe '.tmpremove' do
            context 'with key' do
              before { @result = Slide.tmpremove(@key) }

              it 'removes tmpfile' do
                expect(FileTest.exist?(EMAKI_ROOT + '/tmp/' + @key)).to be false
              end

              it 'returns tmpfile fullpath list' do
                expect(@result).to eq [EMAKI_ROOT + '/tmp/' + @key]
              end
            end
            context 'without key' do
              before { @result = Slide.tmpremove('') }

              it 'returns nil' do
                expect(@result).to be nil
              end

              it 'doesnot remove tmpfile' do
                expect(FileTest.exist?(EMAKI_ROOT + '/tmp/' + @key)).to be true
              end
            end
          end
        end
      end

      # -------------------------------------------------------------
      # safety
      #
      describe '.tmppath' do
        it { expect(Slide.tmppath).to eq "#{EMAKI_ROOT}/tmp" }
      end
      describe '.tmp' do
        before do
          FileUtils.rm_rf(EMAKI_ROOT + '/tmp')
          Slide.tmp
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
              key = Slide.maketmpkey('duplicated.pdf')
              count[key] = true
            end
            expect(count.keys.length).to be 10_000
          end
        end
      end
    end

    #
    # and more...
    #
  end
end
