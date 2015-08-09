require 'RMagick'

# ----------------------------------------------------------------
# Slide
#
# emakiからスライドの実態を隠蔽するクラス。
# TODO: moduleにしたほうがいいのでは？
#
# スライドをディレクトリに保存したり、
# アップロードされたとき一時保存したり、
# スライドのファイルパスを返したりする。
#
class Slide
  def self.logger
    @internal_logger ||= Rack::NullLogger.new nil
  end

  def self.makepath(un, sn)
    EMAKI_ROOT + "/slides/#{un}/#{sn}"
  end

  def self.mkdir(un, sn, logger = self.logger)
    # TODO: It is too danger, I need another way
    # mkdir -p slides/#{un}/#{sn}
    return false if un.nil? || sn.nil?
    path = makepath(un, sn)
    logger.info("MKDIR #{path}")
    begin
      FileUtils.mkdir_p path
    rescue => e
      logger.error(e.message + e.backtrace[0])
      return false
    end
    path
  end

  def self.rmdir(un, sn, logger = self.logger)
    return false if un.nil? || sn.nil?
    path = makepath(un, sn)
    logger.info("RMDIR #{path}")
    begin
      FileUtils.rm_rf path
    rescue => e
      logger.error(e.message + e.backtrace[0])
      return false
    end

    path
  end

  def self.exist?(un, sn)
    FileTest.exist?(makepath(un, sn))
  end
  # --------------------------------------------------------------
  # tmp/ にファイルを保存し、keyを返す
  def self.tmpsave(file, logger = self.logger)
    tmp
    key = maketmpkey(file[:filename])
    begin
      File.open(tmppath + '/' + key, 'wb') { |f| f.write file[:tempfile].read }
    rescue => e
      logger.error(e.message + e.backtrace[0])
      return nil
    end
    key
  end

  def self.tmpremove(key, logger = self.logger)
    path = tmppath + '/' + key
    begin
      FileUtils.remove path
    rescue => e
      logger.error('tmpremove failed.')
      logger.error(e.message + e.backtrace[0])
    end
  end

  def self.tmppath
    EMAKI_ROOT + '/tmp'
  end

  # ./tmpを作成
  def self.tmp
    return true if FileTest.exist?(tmppath)
    FileUtils.mkdir(tmppath)
  end

  def self.maketmpkey(base)
    (0...8).map { (65 + rand(26)).chr }.join +
    '_' +
    Time.now.strftime('%Y%m%d%H%M%S') +
    base
  end
end
