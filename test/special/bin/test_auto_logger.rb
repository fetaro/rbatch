require 'test/unit'
require 'rbatch'

class LoggerTest < Test::Unit::TestCase
  def setup
    @log_dir  = File.join(File.dirname(RBatch.program_name), "..", "log")
    @log_dir2 = File.join(File.dirname(RBatch.program_name), "..", "log2")
    @path  =  File.join(@log_dir , "testunit.log")
    @path2 =  File.join(@log_dir , "testunit2.log")
    Dir::mkdir(@log_dir)if ! Dir.exists? @log_dir
    Dir::mkdir(@log_dir2)if ! Dir.exists? @log_dir2
#    RBatch::Log.debug = true
  end

  def teardown
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(File.join(@log_dir , f)) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@log_dir)
    end
    if Dir.exists? @log_dir2
      Dir::foreach(@log_dir2) do |f|
        File::delete(File.join(@log_dir2 , f)) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@log_dir2)
    end
  end

  def test_log
    RBatch::Log.new do | log |
      log.info("hoge")
    end
    Dir::foreach(@log_dir) do |f|
      if ! (/\.+$/ =~ f)
        assert_match /hoge/, open(File.join(@log_dir , f)).read
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
    assert_match /hoge/, open(File.join(@log_dir , "testprefix_test_auto_logger.log")).read
  end

  def test_change_log_dir
    RBatch::Log.new({:output_dir=> @log_dir2 }) do | log |
      log.info("hoge")
    end
    Dir::foreach(@log_dir2) do |f|
      if ! (/\.+$/ =~ f)
        assert_match /hoge/, open(File.join(@log_dir2 , f)).read
      end
    end
  end

  def test_change_path
    RBatch::Log.new({:path => @path }) do | log |
      log.info("hoge")
    end
    assert_match /hoge/, open(@path).read
  end


  def test_nest_block
    RBatch::Log.new({:path => @path }) do | log |
      log.info("hoge")
      RBatch::Log.new({:path => @path2 }) do | log |
        log.info("bar")
      end
    end
    assert_match /hoge/, open(@path).read
    assert_match /bar/, open(@path2).read
  end

  def test_change_formatte
    RBatch::Log.new({:path => @path , :formatter => proc { |severity, datetime, progname, msg| "hogehoge#{msg}\n" }}) do | log |
      log.info("bar")
    end
    assert_match /hogehogebar/, open(@path).read
  end
end

