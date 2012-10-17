require 'test/unit'
require 'rbatch/auto_logger'

class LoggerTest < Test::Unit::TestCase
  def setup
    @log_dir =  "./test/log/"
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(@log_dir+f) if ! (/\.+$/ =~ f)
      end
    else
      Dir::mkdir(@log_dir)
    end
  end

  def teardown
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(@log_dir+f) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@log_dir)
    end
  end

  def test_infolog
    RBatch::auto_logger do | log |
      log.info("hoge")
    end
  end

  def test_log_dir_doesnot_exist
    Dir::rmdir(@log_dir)
    assert_raise(Errno::ENOENT){
      RBatch::auto_logger {|log|}
    }
  end
end

