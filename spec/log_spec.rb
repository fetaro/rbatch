require 'rbatch/journal'
require 'rbatch/vars'
require 'rbatch/log'
require 'tmpdir'

describe RBatch::Log do

  before :each do
    @home = File.join(Dir.tmpdir, "rbatch_test_" + rand.to_s)
    @log_dir = File.join(@home,"log")
    ENV["RB_HOME"]=@home

    Dir.mkdir(@home)
    Dir::mkdir(@log_dir)
    @vars = RBatch::Vars.new()
    @journal = RBatch::Journal.new(0)
  end

  after :each do
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(File.join(@log_dir , f)) if ! (/\.+$/ =~ f)
      end
    end
    Dir::rmdir(@log_dir)
    Dir::rmdir(@home)
    @vars = nil
  end

  it "is run" do
    block = Proc.new do | log |
      log.info("test_log")
    end
    RBatch::Log.new(@vars,@journal,{},block)
    Dir::foreach(@log_dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@log_dir , f)) {|f|
          expect(f.read).to match /test_log/
        }
      end
    end
  end

  it "raise error when log dir does not exist" do
    Dir::rmdir(@log_dir)
    expect{
      block = Proc.new {|log|}
      RBatch::Log.new(@vars,@journal,{},block)
    }.to raise_error(RBatch::Log::Exception)
    Dir::mkdir(@log_dir)
  end

  it "run when log block is nested" do
    block = Proc.new do | log |
      log.info("name1")
      block2 = Proc.new do | log |
        log.info("name2")
      end
      RBatch::Log.new(@vars,@journal,{:name => "name2" },block2)
    end
    RBatch::Log.new(@vars,@journal,{:name => "name1" },block)

    File::open(File.join(@log_dir,"name1")) {|f| expect(f.read).to match /name1/ }
    File::open(File.join(@log_dir,"name2")) {|f| expect(f.read).to match /name2/ }
  end

  describe "option by argument" do
    it "change log name" do
      opt = {:name => "name1.log" }
      block = Proc.new { | log | log.info("hoge") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "name1.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log name 2" do
      opt = {:name => "<prog><date>name.log" }
      block = Proc.new { | log | log.info("hoge") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir ,  "rspec" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

   it "change log name 3" do
      opt = {:name => "<prog>-<date>-name.log" }
      block = Proc.new { | log | log.info("hoge") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir ,  "rspec-" + Time.now.strftime("%Y%m%d") + "-name.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log dir" do
      @tmp = File.join(ENV["RB_HOME"],"log3")
      Dir.mkdir(@tmp)
      opt = {:name => "c.log", :dir=> @tmp }
      block = Proc.new { | log | log.info("hoge") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@tmp , "c.log")) {|f|
        expect(f.read).to match /hoge/
      }
      FileUtils.rm(File.join(@tmp , "c.log"))
      Dir.rmdir(@tmp)
    end

    it "is append mode" do
      opt = {:append => true, :name =>  "a.log" }
      block = Proc.new { | log | log.info("line1") }
      RBatch::Log.new(@vars,@journal,opt,block)

      opt = {:append => true, :name =>  "a.log" }
      block = Proc.new { | log | log.info("line2") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to match /line1/
        expect(str).to match /line2/
      }
    end

    it "is overwrite mode" do
      opt = {:append => false, :name =>  "a.log" }
      block = Proc.new { | log | log.info("line1") }
      RBatch::Log.new(@vars,@journal,opt,block)

      opt = {:append => false, :name =>  "a.log" }
      block = Proc.new { | log | log.info("line2") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /line1/
        expect(str).to match /line2/
      }
    end

    it "is debug level" do
      opt = { :level => "debug",:name =>  "a.log" }
      block = Proc.new do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is info level" do
      opt = { :level => "info",:name =>  "a.log" }
      block = Proc.new do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is warn level" do
      opt = { :level => "warn",:name =>  "a.log" }
      block = Proc.new do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is error level" do
      opt = { :level => "error",:name =>  "a.log" }
      block = Proc.new do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to_not match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is fatal level" do
      opt = { :level => "fatal",:name =>  "a.log" }
      block = Proc.new do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to_not match /test_warn/
        expect(str).to_not match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is default level" do
      opt = {:name =>  "a.log" }
      block = Proc.new do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "a.log")) {|f|
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
        File.join(@log_dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
      end
      FileUtils.touch(loglist)

      opt = { :name =>  "<date>_test_delete.log",:delete_old_log => true}
      block = Proc.new { | log | }
      RBatch::Log.new(@vars,@journal,opt,block)

      loglist[1..6].each do |filename|
        expect(File.exists?(filename)).to be true
      end
      loglist[7..20].each do |filename|
        expect(File.exists?(filename)).to be false
      end
    end

    it "delete old log which name include <date> even if <date> position is changed" do
      loglist = [*0..20].map do |day|
        File.join(@log_dir , "235959-" + (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
      end
      FileUtils.touch(loglist)

      opt = { :name =>  "<time>-<date>_test_delete.log",:delete_old_log => true}
      block = Proc.new { | log | }
      RBatch::Log.new(@vars,@journal,opt,block)

      loglist[1..6].each do |filename|
        expect(File.exists?(filename)).to be true
      end
      loglist[7..20].each do |filename|
        expect(File.exists?(filename)).to be false
      end
    end

    it "does not delete old log which name does not include <date>" do
      opt = { :name =>  "test_delete.log",:delete_old_log => true}
      block = Proc.new { | log | }
      RBatch::Log.new(@vars,@journal,opt,block)

      expect(File.exists?(File.join(@log_dir,"test_delete.log"))).to be true
    end


  end

  describe "option by run_conf" do
    it "change log name" do
      @vars.merge!({:log_name => "name1.log"})
      opt = {}
      block = Proc.new { | log | log.info("hoge") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "name1.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log dir" do
      @tmp = File.join(ENV["RB_HOME"],"log2")
      Dir.mkdir(@tmp)
      @vars.merge!({:log_dir => @tmp})
      opt = {:name => "c.log" }
      block = Proc.new { | log | log.info("hoge") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@tmp , "c.log")) {|f|
        expect(f.read).to match /hoge/
      }
      FileUtils.rm(File.join(@tmp , "c.log"))
      Dir.rmdir(@tmp)
    end
  end
  describe "option both run_conf and opt" do
    it "change log name" do
      @vars.merge!({:log_name => "name1.log"})
      opt = {:name => "name2.log"}
      block = Proc.new { | log | log.info("hoge") }
      RBatch::Log.new(@vars,@journal,opt,block)

      File::open(File.join(@log_dir , "name2.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end
  end
end
