require 'test/unit'
class LoggerTest < Test::Unit::TestCase
  def setup
  end

  def normal
    require '../lib/rbatch/auto_logger'
    RBatch::auto_logger do | log |
      log.info("hoge")
      unko
    end
  end
end



    require '../lib/rbatch/auto_logger'
    RBatch::auto_logger do | log |
      log.info("hoge")
      unko
    end

