require 'test/unit'
require 'fileutils'
require 'rbatch'
class LoggerTest < Test::Unit::TestCase
  def setup
    @dir  = File.join(File.dirname(RBatch.program_name), "..", "log")
    @dir2 = File.join(File.dirname(RBatch.program_name), "..", "log2")
    @dir3 = File.join(File.dirname(RBatch.program_name), "..", "log3")
    @config_dir =  File.join(File.dirname(RBatch.program_name), "..", "conf")
    Dir::mkdir(@dir)if ! Dir.exists? @dir
    Dir::mkdir(@dir2)if ! Dir.exists? @dir2
    Dir::mkdir(@config_dir) if ! Dir.exists? @config_dir
#    RBatch::Log.verbose = true
    # set STDOUT Logger stop
    confstr = "log_quiet: true\n"
    open( RBatch.common_config_path  , "w" ){|f| f.write(confstr)}

  end

  def teardown
    File::delete(RBatch.common_config_path) if File.exists?(RBatch.common_config_path)
    if Dir.exists? @dir
      Dir::foreach(@dir) do |f|
        File::delete(File.join(@dir , f)) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@dir)
    end
    if Dir.exists? @dir2
      Dir::foreach(@dir2) do |f|
        File::delete(File.join(@dir2 , f)) if ! (/\.+$/ =~ f)
      end
      Dir::rmdir(@dir2)
    end
  end

  def testlog
    RBatch::Log.new do | log |
      log.info("test_log")
    end
    Dir::foreach(@dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir , f)) {|f|
          assert_match /test_log/, f.read
        }
      end
    end
  end

  def test_log_dir_doesnot_exist
    Dir::rmdir(@dir)
    assert_raise(Errno::ENOENT){
      RBatch::Log.new {|log|}
    }
    Dir::mkdir(@dir)
  end

  def test_change_name_by_opt
    RBatch::Log.new({:name => "name1.log" }) do | log |
      log.info("test_change_name_by_opt")
    end
    File::open(File.join(@dir , "name1.log")) {|f|
      assert_match /test_change_name_by_opt/, f.read
    }
  end

  def test_change_name_by_opt2
    RBatch::Log.new({:name => "<prog><date>name.log" }) do | log |
      log.info("test_change_name_by_opt2")
    end
    File::open(File.join(@dir ,  "test_log" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
      assert_match /test_change_name_by_opt2/, f.read
    }
  end

  def test_change_name_by_opt3
    RBatch::Log.new({:name => "<prog>-<date>-name.log" }) do | log |
      log.info("test_change_name_by_opt2")
    end
    File::open(File.join(@dir ,  "test_log-" + Time.now.strftime("%Y%m%d") + "-name.log")) {|f|
      assert_match /test_change_name_by_opt2/, f.read
    }
  end


  def test_change_name_by_config
    confstr = "log_name: name1"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}
    RBatch::Log.new({:name => "name1.log" }) do | log |
      log.info("test_change_name_by_config")
    end
    File::open(File.join(@dir , "name1.log")) {|f|
      assert_match /test_change_name_by_config/, f.read
    }
  end


  def test_change_log_dir_by_opt
    RBatch::Log.new({:output_dir=> @dir2 }) do | log |
      log.info("test_change_log_dir_by_opt")
    end
    Dir::foreach(@dir2) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir2 , f)) {|f|
          assert_match /test_change_log_dir_by_opt/, f.read
        }
      end
    end
  end

  def test_change_log_dir_by_config
    confstr = "log_dir: " + @dir2
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}
    RBatch::Log.new({:output_dir=> @dir2 }) do | log |
      log.info("test_change_log_dir_by_config")
    end
    Dir::foreach(@dir2) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir2 , f)) {|f|
          assert_match /test_change_log_dir_by_config/, f.read
        }
      end
    end
  end

  def test_nest_block
    RBatch::Log.new({:name => "name1" }) do | log |
      log.info("name1")
      RBatch::Log.new({:name => "name2" }) do | log |
        log.info("name2")
      end
    end
    File::open(File.join(@dir,"name1")) {|f| assert_match /name1/, f.read }
    File::open(File.join(@dir,"name2")) {|f| assert_match /name2/, f.read }
  end

  def test_opt_overwite_config
    confstr = "log_name: " + "name1"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}
    RBatch::Log.new({:name => "name2" }) do | log |
      log.info("test_opt_overwite_config")
    end
    File::open(File.join(@dir , "name2")) {|f|
      assert_match /test_opt_overwite_config/, f.read
    }
  end

  def test_append_by_opt
    RBatch::Log.new({:append => true, :name =>  "test_append" }) do | log |
      log.info("test_append1")
    end
    RBatch::Log.new({:append => true, :name =>  "test_append" }) do | log |
      log.info("test_append2")
    end
    File::open(File.join(@dir , "test_append")) {|f|
      str = f.read
      assert_match /test_append1/, str
      assert_match /test_append2/, str
    }
  end

  def test_no_append_by_opt
    RBatch::Log.new({:append => false, :name =>  "test_append" }) do | log |
      log.info("test_append1")
    end
    RBatch::Log.new({:append => false, :name =>  "test_append" }) do | log |
      log.info("test_append2")
    end
    File::open(File.join(@dir , "test_append")) {|f|
      str = f.read
      assert_no_match /test_append1/, str
      assert_match /test_append2/, str
    }
  end


  def test_append_by_conf
    confstr = "log_append: true"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}

    RBatch::Log.new({:name =>  "test_append" }) do | log |
      log.info("test_append1")
    end
    RBatch::Log.new({:name =>  "test_append" }) do | log |
      log.info("test_append2")
    end
    File::open(File.join(@dir , "test_append")) {|f|
      str = f.read
      assert_match /test_append1/, str
      assert_match /test_append2/, str
    }
  end

  def test_no_append_by_conf
    confstr = "log_append: false"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}

    RBatch::Log.new({ :name =>  "test_append" }) do | log |
      log.info("test_append1")
    end
    RBatch::Log.new({ :name =>  "test_append" }) do | log |
      log.info("test_append2")
    end
    File::open(File.join(@dir , "test_append")) {|f|
      str = f.read
      assert_no_match /test_append1/, str
      assert_match /test_append2/, str
    }
  end

 def test_log_level_default
    RBatch::Log.new({ :name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

  def test_log_level_debug_by_opt
    RBatch::Log.new({ :level => "debug",:name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_info_by_opt
    RBatch::Log.new({ :level => "info",:name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_warn_by_opt
    RBatch::Log.new({ :level => "warn",:name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_no_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_error_by_opt
    RBatch::Log.new({ :level => "error",:name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_no_match /test_info/, str
      assert_no_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_fatal_by_opt
    RBatch::Log.new({ :level => "fatal",:name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_no_match /test_info/, str
      assert_no_match /test_warn/, str
      assert_no_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end


  def test_log_level_debug_by_conf
    confstr = "log_level: debug"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}

    RBatch::Log.new({ :name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_info_by_conf
    confstr = "log_level: info"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}
    RBatch::Log.new({ :name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_warn_by_conf
    confstr = "log_level: warn"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}
    RBatch::Log.new({ :name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_no_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_error_by_conf
    confstr = "log_level: error"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}
    RBatch::Log.new({ :name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_no_match /test_info/, str
      assert_no_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

 def test_log_level_fatal_by_conf
    confstr = "log_level: fatal"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}
    RBatch::Log.new({ :name =>  "test_level" }) do | log |
      log.debug("test_debug")
      log.info("test_info")
      log.warn("test_warn")
      log.error("test_error")
      log.fatal("test_fatal")
    end
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_no_match /test_info/, str
      assert_no_match /test_warn/, str
      assert_no_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end


  def test_i_log
    log = RBatch::Log.new
    assert_not_nil log
    log.info("test_log")
    log.close
    Dir::foreach(@dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir , f)) {|f|
          assert_match /test_log/, f.read
        }
      end
    end
  end

  def test_i_log_dir_doesnot_exist
    Dir::rmdir(@dir)
    assert_raise(Errno::ENOENT){
      log = RBatch::Log.new
      log.close
    }
    Dir::mkdir(@dir)
  end

  def test_i_change_name_by_opt
    log = RBatch::Log.new({:name => "name1.log" })
    log.info("test_change_name_by_opt")
    log.close
    File::open(File.join(@dir , "name1.log")) {|f|
      assert_match /test_change_name_by_opt/, f.read
    }
  end

  def test_i_change_name_by_opt2
    log = RBatch::Log.new({:name => "<prog><date>name.log" })
    log.info("test_change_name_by_opt2")
    log.close
    File::open(File.join(@dir ,  "test_log" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
      assert_match /test_change_name_by_opt2/, f.read
    }
  end

  
  def test_i_log_level_default
    log = RBatch::Log.new({ :name =>  "test_level" })
    log.debug("test_debug")
    log.info("test_info")
    log.warn("test_warn")
    log.error("test_error")
    log.fatal("test_fatal")
    log.close

    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_no_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

  def test_i_log_level_debug_by_opt
    log = RBatch::Log.new({ :level => "debug",:name =>  "test_level" })
    log.debug("test_debug")
    log.info("test_info")
    log.warn("test_warn")
    log.error("test_error")
    log.fatal("test_fatal")
    log.close
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end


  def test_i_log_level_debug_by_conf
    confstr = "log_level: debug"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}

    log = RBatch::Log.new({ :name =>  "test_level" })
    log.debug("test_debug")
    log.info("test_info")
    log.warn("test_warn")
    log.error("test_error")
    log.fatal("test_fatal")
    log.close
    File::open(File.join(@dir , "test_level")) {|f|
      str = f.read
      assert_match /test_debug/, str
      assert_match /test_info/, str
      assert_match /test_warn/, str
      assert_match /test_error/, str
      assert_match /test_fatal/, str
    }
  end

  def test_delete_old_log_by_opt
    loglist = [*0..20].map do |day|
      File.join(@dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
    end
    FileUtils.touch(loglist)
    log = RBatch::Log.new({ :name =>  "<date>_test_delete.log",:delete_old_log => true})
    log.close
    loglist[1..6].each do |filename|
      assert File.exists?(filename), "log file \"#{filename}\" should be exist"
    end
    loglist[7..20].each do |filename|
      assert ! File.exists?(filename), "log file \"#{filename}\" should NOT be exist"
    end
  end
  def test_delete_old_log_by_config
    confstr = "log_delete_old_log: true"
    open( RBatch.common_config_path  , "a" ){|f| f.write(confstr)}

    loglist = [*0..20].map do |day|
      File.join(@dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
    end
    FileUtils.touch(loglist)
    log = RBatch::Log.new({ :name =>  "<date>_test_delete.log"})
    log.close
    loglist[1..6].each do |filename|
      assert File.exists?(filename), "log file \"#{filename}\" should be exist"
    end
    loglist[7..20].each do |filename|
      assert ! File.exists?(filename), "log file \"#{filename}\" should NOT be exist"
    end
  end

  def test_delete_old_log_file_format_change_with_time
    loglist = [*0..20].map do |day|
      File.join(@dir , "235959-" + (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
    end
    FileUtils.touch(loglist)
    log = RBatch::Log.new({ :name =>  "<time>-<date>_test_delete.log",:delete_old_log => true})
    log.close
    loglist[1..6].each do |filename|
      assert File.exists?(filename), "log file \"#{filename}\" should be exist"
    end
    loglist[7..20].each do |filename|
      assert ! File.exists?(filename), "log file \"#{filename}\" should NOT be exist"
    end
  end

  def test_delete_old_log_file_format_change_no_date
    log = RBatch::Log.new({ :name =>  "test_delete.log",:delete_old_log => true})
    log.close
    assert File.exists?(File.join(@dir,"test_delete.log")), "log file \"test_delete.log\" should be exist"
  end

  def test_delete_old_log_date
    loglist = [*0..20].map do |day|
      File.join(@dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
    end
    FileUtils.touch(loglist)
    log = RBatch::Log.new({ :name =>  "<date>_test_delete.log",:delete_old_log => true,:delete_old_log_date => 5})
    log.close
    loglist[1..4].each do |filename|
      assert File.exists?(filename), "log file \"#{filename}\" should be exist"
    end
    loglist[5..20].each do |filename|
      assert ! File.exists?(filename), "log file \"#{filename}\" should NOT be exist"
    end
  end


end

