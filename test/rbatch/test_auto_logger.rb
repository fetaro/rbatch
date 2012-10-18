require 'test/unit'
require 'rbatch/auto_logger'

class LoggerTest < Test::Unit::TestCase
  def setup
    @log_dir =  "./test/log/"
    Dir::mkdir(@log_dir)if ! Dir.exists? @log_dir
    RBatch::Log::file_prefix = "%Y%m%d_%H%M%S_"
    RBatch::Log::output_dir = @log_dir
  end

  def teardown
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(@log_dir + f) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@log_dir)
    end
  end

  def test_infolog
    RBatch::Log::record do | log |
      log.info("hoge")
    end
    Dir::foreach(@log_dir) do |f|
      if ! (/\.+$/ =~ f)
        assert_match /hoge/, open(@log_dir + f).read
      end
    end
  end

  def test_log_dir_doesnot_exist
    Dir::rmdir(@log_dir)
    assert_raise(Errno::ENOENT){
      RBatch::Log::record {|log|}
    }
    Dir::mkdir(@log_dir)
  end

  def test_change_file_prefix_by_method
    RBatch::Log::file_prefix = "testprefix_"
    assert_equal "testprefix_",RBatch::Log::file_prefix
    RBatch::Log::record do | log |
      log.info("hoge")
    end
    assert_match /hoge/, open(@log_dir + "testprefix_test_auto_logger.log").read
  end

  def test_change_log_format_by_args
    RBatch::Log::record({:file_prefix => "testprefix_"}) do | log |
      log.info("hoge")
    end
    assert_match /hoge/, open(@log_dir + "testprefix_test_auto_logger.log").read
  end

  def test_change_log_dir_by_method
    log_dir2 = File.join( @log_dir , ".." , "log2")
    Dir::mkdir(log_dir2) if ! Dir::exist?(log_dir2)
    RBatch::Log::output_dir = log_dir2
    assert_equal log_dir2,RBatch::Log::output_dir
    RBatch::Log::record do | log |
      log.info("hoge")
    end
    Dir::foreach(log_dir2) do |f|
      if ! (/\.+$/ =~ f)
        assert_match /hoge/, open(File.join(log_dir2 , f)).read
      end
    end
  end

  def test_change_log_dir_by_args
    log_dir2 = File.join( @log_dir , ".." , "log2")
    RBatch::Log::record({:output_dir=> log_dir2 }) do | log |
      log.info("hoge")
    end
    Dir::foreach(log_dir2) do |f|
      if ! (/\.+$/ =~ f)
        assert_match /hoge/, open(File.join(log_dir2 , f)).read
      end
    end
  end

end

