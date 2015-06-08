require 'simplecov'
SimpleCov.start

require 'rbatch/journal'
require 'rbatch/variables'
require 'rbatch/log'
require 'tmpdir'

describe RBatch::Log do
  before :each do
    @home = File.join(Dir.tmpdir, "rbatch_test_" + rand.to_s)
    @log_dir = File.join(@home,"log")
    ENV["RB_HOME"]=@home

    Dir.mkdir(@home)
    Dir::mkdir(@log_dir)
    @def_vars = RBatch::Variables.new()
    RBatch::Log.def_vars = @def_vars
    RBatch::Journal.def_vars = @def_vars
    @journal = RBatch::Journal.new(0)
    RBatch::Log.journal = @journal
  end

  after :each do
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(File.join(@log_dir , f)) if ! (/\.+$/ =~ f)
      end
    end
    Dir::rmdir(@log_dir)
    Dir::rmdir(@home)
    @def_vars = nil
    @journal = nil
  end

  it "is run" do
    RBatch::Log.new do | log |
      log.info("test_log")
    end

    Dir::foreach(@log_dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@log_dir , f)) {|f|
          expect(f.read).to match /test_log/
        }
      end
    end
  end

  it "is rescue exception" do
    expect { 
      RBatch::Log.new do | log |
        raise Exception.new
      end
    }.to raise_error SystemExit
  end

  it "catch SystemExit 0 " do
    expect { 
      RBatch::Log.new do | log |
        exit 0
      end
    }.to raise_error SystemExit do |e|
      expect(e.status).to eq 0
    end
  end

  it "catch SystemExit 3" do
    expect { 
      RBatch::Log.new do | log |
        exit 3
      end
    }.to raise_error SystemExit do |e|
      expect(e.status).to eq 3
    end
  end

  it "raise error when log dir does not exist" do
    Dir::rmdir(@log_dir)
    expect{
      RBatch::Log.new {|log|}
    }.to raise_error(RBatch::LogException)
    Dir::mkdir(@log_dir)
  end

  it "run when log block is nested" do
    RBatch::Log.new({:name => "name1"}) do | log |
      log.info("name1")
      RBatch::Log.new({:name => "name2"})do | log |
        log.info("name2")
      end
    end

    File::open(File.join(@log_dir,"name1")) {|f| expect(f.read).to match /name1/ }
    File::open(File.join(@log_dir,"name2")) {|f| expect(f.read).to match /name2/ }
  end

  describe "option by argument" do
    describe ":name option" do
      it "change log name" do
        opt = {:name => "name1.log" }
        RBatch::Log.new(opt) { | log | log.info("hoge") }
        File::open(File.join(@log_dir , "name1.log")) {|f|
          expect(f.read).to match /hoge/
        }
      end
      
      it "change log name 2" do
        opt = {:name => "<prog><date>name.log" }
        RBatch::Log.new(opt) { | log | log.info("hoge") }
        
        File::open(File.join(@log_dir ,  "rspec" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
          expect(f.read).to match /hoge/
        }
      end
      
      it "change log name 3" do
        opt = {:name => "<prog>-<date>-name.log" }
        RBatch::Log.new(opt) { | log | log.info("hoge") }
        
        File::open(File.join(@log_dir ,  "rspec-" + Time.now.strftime("%Y%m%d") + "-name.log")) {|f|
          expect(f.read).to match /hoge/
        }
      end
    end
    
    describe ":dir option" do
      it "change log dir" do
        @tmp = File.join(ENV["RB_HOME"],"log3")
        Dir.mkdir(@tmp)
        opt = {:name => "c.log", :dir=> @tmp }
        RBatch::Log.new(opt) { | log | log.info("hoge") }
        
        File::open(File.join(@tmp , "c.log")) {|f|
          expect(f.read).to match /hoge/
        }
        FileUtils.rm(File.join(@tmp , "c.log"))
        Dir.rmdir(@tmp)
      end
    end

    describe ":append option" do
      it "is append mode" do
        opt = {:append => true, :name =>  "a.log" }
        RBatch::Log.new(opt) { | log | log.info("line1") }
        
        opt = {:append => true, :name =>  "a.log" }
        RBatch::Log.new(opt) { | log | log.info("line2") }
        
        File::open(File.join(@log_dir , "a.log")) {|f|
          str = f.read
          expect(str).to match /line1/
          expect(str).to match /line2/
        }
      end
      
      it "is overwrite mode" do
        opt = {:append => false, :name =>  "a.log" }
        RBatch::Log.new(opt) { | log | log.info("line1") }
        
        opt = {:append => false, :name =>  "a.log" }
        RBatch::Log.new(opt) { | log | log.info("line2") }
        
        File::open(File.join(@log_dir , "a.log")) {|f|
          str = f.read
          expect(str).to_not match /line1/
          expect(str).to match /line2/
        }
      end
    end
    describe ":level option" do
      it "is debug level" do
        opt = { :level => "debug",:name =>  "a.log" }
        RBatch::Log.new(opt) do | log |
          log.debug("test_debug")
          log.info("test_info")
          log.warn("test_warn")
          log.error("test_error")
          log.fatal("test_fatal")
        end
        
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
        RBatch::Log.new(opt) do | log |
          log.debug("test_debug")
          log.info("test_info")
          log.warn("test_warn")
          log.error("test_error")
          log.fatal("test_fatal")
        end
        
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
        RBatch::Log.new(opt) do | log |
          log.debug("test_debug")
          log.info("test_info")
          log.warn("test_warn")
          log.error("test_error")
          log.fatal("test_fatal")
        end
        
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
        RBatch::Log.new(opt) do | log |
          log.debug("test_debug")
          log.info("test_info")
          log.warn("test_warn")
          log.error("test_error")
          log.fatal("test_fatal")
        end
        
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
        RBatch::Log.new(opt) do | log |
          log.debug("test_debug")
          log.info("test_info")
          log.warn("test_warn")
          log.error("test_error")
          log.fatal("test_fatal")
        end
        
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
        RBatch::Log.new(opt) do | log |
          log.debug("test_debug")
          log.info("test_info")
          log.warn("test_warn")
          log.error("test_error")
          log.fatal("test_fatal")
        end
        
        File::open(File.join(@log_dir , "a.log")) {|f|
          str = f.read
          expect(str).to_not match /test_debug/
          expect(str).to match /test_info/
          expect(str).to match /test_warn/
          expect(str).to match /test_error/
          expect(str).to match /test_fatal/
        }
      end
    end
    describe ":delete_old_log option" do
      it "delete old log which name include <date>" do
        loglist = [*0..20].map do |day|
          File.join(@log_dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
        end
        FileUtils.touch(loglist)
        
        opt = { :name =>  "<date>_test_delete.log",:delete_old_log => true}
        RBatch::Log.new(opt) { | log | }
        
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
        RBatch::Log.new(opt) { | log | }
        
        loglist[1..6].each do |filename|
          expect(File.exists?(filename)).to be true
        end
        loglist[7..20].each do |filename|
          expect(File.exists?(filename)).to be false
        end
      end
      
      it "does not delete old log which name does not include <date>" do
        opt = { :name =>  "test_delete.log",:delete_old_log => true}
        RBatch::Log.new(opt) { | log | }
        
        expect(File.exists?(File.join(@log_dir,"test_delete.log"))).to be true
      end
    end
    
    describe ":bufferd option" do
      it "works bufferd is true" do
        opt = { :name =>  "test_buffer.log",:bufferd => true}
        RBatch::Log.new(opt) { | log | log.info("hoge") }
        File::open(File.join(@log_dir , "test_buffer.log")) {|f|
          expect(f.read).to match /hoge/
        }
      end
      it "works bufferd is false" do
        opt = { :name =>  "test_buffer2.log",:bufferd => false}
        RBatch::Log.new(opt) { | log | log.info("hoge") }
        File::open(File.join(@log_dir , "test_buffer2.log")) {|f|
          expect(f.read).to match /hoge/
        }
      end
    end

  end

  describe "option by run_conf" do
    describe "log_name option" do
      it "change log name" do
        @def_vars.merge!({:log_name => "name1.log"})
        RBatch::Log.def_vars = @def_vars
        RBatch::Log.new { | log | log.info("hoge") }
        
        File::open(File.join(@log_dir , "name1.log")) {|f|
          expect(f.read).to match /hoge/
        }
      end
    end

    describe "log_dir option" do
      it "change log dir" do
        @tmp = File.join(ENV["RB_HOME"],"log2")
        Dir.mkdir(@tmp)
        @def_vars.merge!({:log_dir => @tmp})
        RBatch::Log.def_vars = @def_vars
        
        opt = {:name => "c.log" }
        RBatch::Log.new(opt) { | log | log.info("hoge") }
        
        File::open(File.join(@tmp , "c.log")) {|f|
          expect(f.read).to match /hoge/
        }
        FileUtils.rm(File.join(@tmp , "c.log"))
        Dir.rmdir(@tmp)
      end
    end
  end
  
  describe "option both run_conf and opt" do
    it "change log name" do
      @def_vars.merge!({:log_name => "name1.log"})
      RBatch::Log.def_vars = @def_vars

      opt = {:name => "name2.log"}
      RBatch::Log.new(opt) { | log | log.info("hoge") }

      File::open(File.join(@log_dir , "name2.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end
  end
end
