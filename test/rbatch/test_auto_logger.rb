require 'test/unit'
class LoggerTest < Test::Unit::TestCase
  def setup
   @log_dir =  "./test/log/"
    Dir::mkdir(@log_dir) if ! Dir.exists? @log_dir
  end

  def test_require
    require './lib/rbatch/auto_logger'
  end
  def test_infolog
    require './lib/rbatch/auto_logger'
    RBatch::auto_logger do | log |
      log.info("hoge")
    end
  end
end

