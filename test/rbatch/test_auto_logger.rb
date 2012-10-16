require 'test/unit'
require 'rbatch/auto_logger'

class LoggerTest < Test::Unit::TestCase
  def setup
   @log_dir =  "./test/log/"
    Dir::mkdir(@log_dir) if ! Dir.exists? @log_dir
  end

  def test_infolog
    RBatch::auto_logger do | log |
      log.info("hoge")
    end
  end
end

