require 'test/unit'
require 'fileutils'
require 'rbatch'
class LoggerTest < Test::Unit::TestCase
  def setup
    @log_dir  = File.join(File.dirname(RBatch.program_name), "..", "log")
    @log_dir2 = File.join(File.dirname(RBatch.program_name), "..", "log2")
    @path  =  File.join(@log_dir , "testunit.log")
    @path2 =  File.join(@log_dir , "testunit2.log")
    @path3 =  File.join(@log_dir , "testunit3.log")

    Dir::mkdir(@log_dir)if ! Dir.exists? @log_dir
    Dir::mkdir(@log_dir2)if ! Dir.exists? @log_dir2

#    RBatch::Log.verbose = true
  end

  def teardown
    File::delete(RBatch.common_config_path) if File.exists?(RBatch.common_config_path)
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

        File::open(File.join(@log_dir , f)) {|f|
          assert_match /hoge/, f.read
        }
        #assert_match /hoge/, open(File.join(@log_dir , f)).read
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

  def test_opt_overwite_config
    confstr = "log_path: " + @path3
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new({:path => @path }) do | log |
      log.info("test_opt_overwite_config")
    end
    File::open(@path) {|f|
      assert_match /test_opt_overwite_config/, f.read
    }
  end

  def test_change_path_by_opt
    RBatch::Log.new({:path => @path }) do | log |
      log.info("test_change_path_by_opt")
    end
    File::open(@path) {|f|
      assert_match /test_change_path_by_opt/, f.read
    }
  end

  def test_change_path_by_config
    confstr = "log_path: " + @path3
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new() do | log |
      log.info("test_change_path_by_config")
    end
    File::open(@path3) {|f| assert_match /test_change_path_by_config/, f.read }
  end



  def test_change_prefix_by_opt
    RBatch::Log.new({:file_prefix => "pref_"}) do | log |
      log.info("test_change_prefix_by_opt")
    end
    File::open(File.join(@log_dir , Time.now.strftime("pref_") + "test_log.log")) {|f|
      assert_match /test_change_prefix_by_opt/, f.read
    }
  end

  def test_change_prefix_by_config
    confstr = "log_file_prefix: pref_"
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new() do | log |
      log.info("test_change_prefix_by_config")
    end
    File::open(File.join(@log_dir , Time.now.strftime("pref_") + "test_log.log")) {|f| assert_match /test_change_prefix_by_config/, f.read }
  end

  def test_change_suffix_by_opt
    RBatch::Log.new({:file_suffix => ".testsuffix"}) do | log |
      log.info("test_change_suffix_by_opt")
    end
    Dir::foreach(@log_dir) do |file|
      if ! (/\.+$/ =~ file)
        assert_match /test_log.testsuffix/ , file
        File::open(File.join(@log_dir , file)) {|f|
          assert_match /test_change_suffix_by_opt/, f.read
        }
      end
    end
  end

  def test_change_suffix_by_config
    confstr = "log_file_suffix: .testsuffix"
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new() do | log |
      log.info("test_change_suffix_by_config")
    end
    Dir::foreach(@log_dir) do |file|
      if ! (/\.+$/ =~ file)
        assert_match /test_log.testsuffix/ , file
        File::open(File.join(@log_dir , file)) {|f|
          assert_match /test_change_suffix_by_config/, f.read
        }
      end
    end
  end

  def test_change_log_dir_by_opt
    RBatch::Log.new({:output_dir=> @log_dir2 }) do | log |
      log.info("test_change_log_dir_by_opt")
    end
    Dir::foreach(@log_dir2) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@log_dir2 , f)) {|f|
          assert_match /test_change_log_dir_by_opt/, f.read
        }
      end
    end
  end

  def test_change_log_dir_by_config
    confstr = "log_output_dir: " + @log_dir2
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}
    RBatch::Log.new({:output_dir=> @log_dir2 }) do | log |
      log.info("test_change_log_dir_by_config")
    end
    Dir::foreach(@log_dir2) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@log_dir2 , f)) {|f|
          assert_match /test_change_log_dir_by_config/, f.read
        }
      end
    end
  end

  def test_change_formatte
    RBatch::Log.new({:path => @path , :formatter => proc { |severity, datetime, progname, msg| "hogehoge#{msg}\n" }}) do | log |
      log.info("bar")
    end
    File::open(@path) {|f| assert_match /hogehogebar/, f.read }
  end

  def test_nest_block
    RBatch::Log.new({:path => @path }) do | log |
      log.info("hoge")
      RBatch::Log.new({:path => @path2 }) do | log |
        log.info("bar")
      end
    end
    File::open(@path) {|f| assert_match /hoge/, f.read }
    File::open(@path2) {|f| assert_match /bar/, f.read }
  end


end

