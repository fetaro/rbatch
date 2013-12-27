require 'tmpdir'
ENV["RB_HOME"]=Dir.tmpdir

require 'rbatch'

describe RBatch::Log do

  before :all do
    @dir = File.join(Dir.tmpdir,"log")
    Dir::mkdir(@dir)if ! Dir.exists? @dir
  end

  before :each do
    open( RBatch.run_conf_path  , "w" ){|f| f.write("log_quiet: true \n")}
    RBatch.run_conf.reload
  end

  after :each do
    Dir::foreach(@dir) do |f|
      File::delete(File.join(@dir , f)) if ! (/\.+$/ =~ f)
    end
    FileUtils.rm(RBatch.run_conf_path) if File.exist?(RBatch.run_conf_path)
  end

  it "is run" do
    RBatch::Log.new do | log |
      log.info("test_log")
    end
    Dir::foreach(@dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir , f)) {|f|
          expect(f.read).to match /test_log/
        }
      end
    end
  end

  it "raise error when log dir does not exist" do
    Dir::rmdir(@dir)
    expect{
      RBatch::Log.new {|log|}
    }.to raise_error(Errno::ENOENT)
    Dir::mkdir(@dir)
  end

  it "run when log block is nested" do
    RBatch::Log.new({:name => "name1" }) do | log |
      log.info("name1")
      RBatch::Log.new({:name => "name2" }) do | log |
        log.info("name2")
      end
    end
    File::open(File.join(@dir,"name1")) {|f| expect(f.read).to match /name1/ }
    File::open(File.join(@dir,"name2")) {|f| expect(f.read).to match /name2/ }
  end

  describe "option by argument" do
    it "change log name" do
      RBatch::Log.new({:name => "name1.log" }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@dir , "name1.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log name 2" do
      RBatch::Log.new({:name => "<prog><date>name.log" }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@dir ,  "rspec" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

   it "change log name 3" do
      RBatch::Log.new({:name => "<prog>-<date>-name.log" }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@dir ,  "rspec-" + Time.now.strftime("%Y%m%d") + "-name.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log dir" do
      @tmp = Dir.tmpdir
      RBatch::Log.new({:name => "c.log", :dir=> @tmp }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@tmp , "c.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "is append mode" do
      RBatch::Log.new({:append => true, :name =>  "a.log" }) do | log |
        log.info("line1")
      end
      RBatch::Log.new({:append => true, :name =>  "a.log" }) do | log |
        log.info("line2")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to match /line1/
        expect(str).to match /line2/
      }
    end

    it "is overwrite mode" do
      RBatch::Log.new({:append => false, :name =>  "a.log" }) do | log |
        log.info("line1")
      end
      RBatch::Log.new({:append => false, :name =>  "a.log" }) do | log |
        log.info("line2")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /line1/
        expect(str).to match /line2/
      }
    end

    it "is debug level" do
      RBatch::Log.new({ :level => "debug",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is info level" do
      RBatch::Log.new({ :level => "info",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is warn level" do
      RBatch::Log.new({ :level => "warn",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is error level" do
      RBatch::Log.new({ :level => "error",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to_not match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is fatal level" do
      RBatch::Log.new({ :level => "fatal",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to_not match /test_warn/
        expect(str).to_not match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is default level" do
      RBatch::Log.new({ :name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "delete old log which name include <date>" do
      loglist = [*0..20].map do |day|
        File.join(@dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
      end
      FileUtils.touch(loglist)
      log = RBatch::Log.new({ :name =>  "<date>_test_delete.log",:delete_old_log => true})
      log.close
      loglist[1..6].each do |filename|
        expect(File.exists?(filename)).to be true
      end
      loglist[7..20].each do |filename|
        expect(File.exists?(filename)).to be false
      end
    end

    it "delete old log which name include <date> even if <date> position is changed" do
      loglist = [*0..20].map do |day|
        File.join(@dir , "235959-" + (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
      end
      FileUtils.touch(loglist)
      log = RBatch::Log.new({ :name =>  "<time>-<date>_test_delete.log",:delete_old_log => true})
      log.close
      loglist[1..6].each do |filename|
        expect(File.exists?(filename)).to be true
      end
      loglist[7..20].each do |filename|
        expect(File.exists?(filename)).to be false
      end
    end

    it "does not delete old log which name does not include <date>" do
      log = RBatch::Log.new({ :name =>  "test_delete.log",:delete_old_log => true})
      log.close
      expect(File.exists?(File.join(@dir,"test_delete.log"))).to be true
    end


  end

  describe "option by config" do
    it "change log name" do
      confstr = "log_name: name1.log"
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      RBatch::Log.new() do | log |
        log.info("hoge")
      end
      File::open(File.join(@dir , "name1.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log dir" do
      @tmp = Dir.tmpdir
      confstr = "log_name: c.log\nlog_dir: " + @tmp
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      RBatch::Log.new({:name => "c.log", :dir=> @tmp }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@tmp , "c.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "is append mode" do
      confstr = "log_name: a.log\nlog_append: true"
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      RBatch::Log.new() do | log |
        log.info("line1")
      end
      RBatch::Log.new() do | log |
        log.info("line2")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to match /line1/
        expect(str).to match /line2/
      }
    end

    it "is overwrite mode" do
      confstr = "log_name: a.log\nlog_append: false"
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      RBatch::Log.new() do | log |
        log.info("line1")
      end
      RBatch::Log.new() do | log |
        log.info("line2")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /line1/
        expect(str).to match /line2/
      }
    end

    it "is warn level" do
      confstr = "log_name: a.log\nlog_level: warn"
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      RBatch::Log.new() do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "delete old log file which name include <date>" do
      confstr = "log_delete_old_log: true"
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      loglist = [*0..20].map do |day|
        File.join(@dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
      end
      FileUtils.touch(loglist)
      log = RBatch::Log.new({ :name =>  "<date>_test_delete.log"})
      log.close
      loglist[1..6].each do |filename|
        expect( File.exists?(filename)).to be true
      end
      loglist[7..20].each do |filename|
        expect( File.exists?(filename)).to be false
      end
    end
  end

  describe "option by both argument and config" do
    it "is prior to argument than config" do
      confstr = "log_name: a.log"
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      RBatch::Log.new({:name => "b.log"}) do | log |
        log.info("hoge")
      end
      File::open(File.join(@dir , "b.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end
  end

  describe "instance" do
    it "run" do
      log = RBatch::Log.new
      expect(log).to_not be_nil
      log.info("test_log")
      log.close
      Dir::foreach(@dir) do |f|
        if ! (/\.+$/ =~ f)
          File::open(File.join(@dir , f)) {|f|
            expect(f.read).to match /test_log/
          }
        end
      end
    end

    it "raise error when log dir does not exist" do
      Dir::rmdir(@dir)
      expect{
        RBatch::Log.new
      }.to raise_error(Errno::ENOENT)
      Dir::mkdir(@dir)
    end

    it "option by argument" do
      log = RBatch::Log.new({:name => "d.log" })
      log.info("hoge")
      log.close
      File::open(File.join(@dir , "d.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end


    it "option by config" do
      confstr = "log_name: e.log"
      open( RBatch.run_conf_path  , "a" ){|f| f.write(confstr)}
      RBatch.run_conf.reload
      log = RBatch::Log.new()
      log.info("hoge")
      log.close
      File::open(File.join(@dir , "e.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end
  end
end
