require File.expand_path '../spec_helper.rb', __FILE__

# slide関連のファイル操作を行うSlideクラスをテスト
describe 'Emaki::Slide' do

  describe '.mkdir' do
    context "(#{UN}, #{SN})" do
      it "(#{UN}, #{SN})  -> create ..../slides/#{UN}/#{SN}"
    end
  end

  describe '.rmdir' do
    #
    # 注意：ユーザーディレクトリは削除しない
    context "(#{UN}, #{SN})" do
      it "(#{UN}, #{SN}) -> remove ..../slides/#{UN}/#{SN}"
    end
  end

  describe '.makepath' do
    context "(#{UN}, #{SN})" do
      it "(#{UN}, #{SN}) -> ..../slides/#{UN}/#{SN}"
    end
  end
end
