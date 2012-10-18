require 'test/unit'
require 'rbatch/auto_logger'

class LoggerTest < Test::Unit::TestCase
  def setup
    @log_dir =  "./test/log/"
    Dir::mkdir(@log_dir)if ! Dir.exists? @log_dir
  end

  def teardown
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(@log_dir + f) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@log_dir)
    end
  end

  def test_log
    RBatch::Log.new do | log |
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
      RBatch::Log.new {|log|}
    }
    Dir::mkdir(@log_dir)
  end

  def test_change_log_format
    RBatch::Log.new({:file_prefix => "testprefix_"}) do | log |
      log.info("hoge")
    end
    assert_match /hoge/, open(@log_dir + "testprefix_test_auto_logger.log").read
  end

  def test_change_log_dir
    log_dir2 = File.join( @log_dir , ".." , "log2")
    RBatch::Log.new({:output_dir=> log_dir2 }) do | log |
      log.info("hoge")
    end
    Dir::foreach(log_dir2) do |f|
      if ! (/\.+$/ =~ f)
        assert_match /hoge/, open(File.join(log_dir2 , f)).read
      end
    end
  end

  def test_change_path
    path = File.join( @log_dir , ".." , "log2" , "test.log" )
    RBatch::Log.new({:path => path }) do | log |
      log.info("hoge")
    end
    assert_match /hoge/, open(path).read
  end


  def test_nest_block
    path = File.join( @log_dir , ".." , "log2" , "test.log" )
    RBatch::Log.new do | log |
      log.info("hoge")
      RBatch::Log.new({:path => path }) do | log |
        log.info("bar")
      end
    end
    Dir::foreach(@log_dir) do |f|
      if ! (/\.+$/ =~ f)
        assert_match /hoge/, open(@log_dir + f).read
      end
    end
    assert_match /bar/, open(path).read
  end

  def test_change_formatte
    path = File.join( @log_dir , ".." , "log2" , "test.log" )
    RBatch::Log.new({:path => path , :formatter => proc { |severity, datetime, progname, msg| "hogehoge#{msg}\n" }}) do | log |
      log.info("bar")
    end
    assert_match /hogehogebar/, open(path).read
  end
end

