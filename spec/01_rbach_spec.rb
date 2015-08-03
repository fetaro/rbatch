require 'tmpdir'

describe "RBatch" do
  before :all do
    @rand = "rbatch_test_" + rand.to_s
    @home = File.join(Dir.tmpdir, @rand)
    @log_dir = File.join(@home,"log")
    @conf_dir = File.join(@home,"conf")
    @lib_dir = File.join(@home,"lib")
    ENV["RB_HOME"]=@home

    Dir.mkdir(@home)
    Dir.mkdir(@log_dir)
    Dir.mkdir(@conf_dir)
    Dir.mkdir(@lib_dir)
    open( File.join(@home,".rbatchrc") , "a" ){|f|
      f.write("log_name : hoge.log \nforbid_double_run : true")
    }

    open( File.join(@conf_dir,"rspec.yaml") , "a" ){|f|
      f.write("key1 : value1")
    }

    open( File.join(@conf_dir,"common.yaml") , "a" ){|f|
      f.write("key2 : value2")
    }

    open( File.join(@lib_dir,"hoge.rb") , "a" ){|f|
      f.write("require 'hoge'\nrequire 'tmp/bar'\nrequire 'tmp/tmp/huga'\n")
    }

    Dir.mkdir(File.join(@lib_dir,"tmp"))
    open( File.join(@lib_dir,"tmp","bar.rb") , "a" ){|f|
      f.write("require 'hoge'\nrequire 'tmp/bar'\nrequire 'tmp/tmp/huga'\n")
    }

    Dir.mkdir(File.join(@lib_dir,"tmp","tmp"))
    open( File.join(@lib_dir,"tmp","tmp","huga.rb") , "a" ){|f|
      f.write("require 'hoge'\nrequire 'tmp/bar'\nrequire 'tmp/tmp/huga'\n")
    }

    # stop STODOUT output
    #$stdout = File.open(File.join(@home,"out.txt"),"w")
    #$stderr = File.open(File.join(@home,"err.txt"),"w")
  end

  after :all do
  #  FileUtils.rm_rf(@home)
  end

  it "success" do
    require 'rbatch'

    result = RBatch.cmd("ruby -e 'STDOUT.print 1; STDERR.print 2; exit 0;'")
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    expect(result.status).to eq 0
    expect{
      RBatch.cmd("ruby -e 'exit 1;'",{:raise => true})
    }.to raise_error(RBatch::CmdException)


    expect(RBatch.config["key1"]).to eq "value1"
    expect{ RBatch.config["noexist"] }.to raise_error RBatch::ConfigException

    expect(RBatch.common_config["key2"]).to eq "value2"
    expect{ RBatch.common_config["noexist"] }.to raise_error RBatch::ConfigException

    expect{
      RBatch::Log.new do |log|
        log.info("test_string")
        RBatch.ctrl.journal.put 2,"var2"
        RBatch.ctrl.journal.put 1,"var1"
        RBatch.ctrl.journal.put 0,"var0"
        RBatch.config["noexist2"]
      end
    }.to raise_error SystemExit

    Dir::foreach(RBatch.vars[:log_dir]) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(RBatch.vars[:log_dir] , f)) {|f|
          expect(f.read).to match /test_string/
        }
      end
    end

    # check journal
    expect(RBatch.ctrl.journal.journals[0]).to match /START RBatch/
    expect(RBatch.ctrl.journal.journals[1]).to match Regexp.new(@rand)
    expect(RBatch.ctrl.journal.journals[2]).to match /batchrc/
    expect(RBatch.ctrl.journal.journals[3]).to match /common.yaml/
    expect(RBatch.ctrl.journal.journals[4]).to match /rspec.yaml/
    expect(RBatch.ctrl.journal.journals[5]).to match /Load Library.*.rb/
    expect(RBatch.ctrl.journal.journals[6]).to match /Load Library.*.rb/
    expect(RBatch.ctrl.journal.journals[7]).to match /Load Library.*.rb/
    expect(RBatch.ctrl.journal.journals[8]).to match /Start Script/
    expect(RBatch.ctrl.journal.journals[9]).to match /Logging Start/
    expect(RBatch.ctrl.journal.journals[10]).to match /var1/
    expect(RBatch.ctrl.journal.journals[11]).to match /var0/

    # check log
    f = open(File.join(@home,"log","hoge.log")).read
    lines = f.split("\n")

    expect(lines[0]).to match /START RBatch/
    expect(lines[1]).to match Regexp.new(@rand)
    expect(lines[2]).to match /batchrc/
    expect(lines[3]).to match /common.yaml/
    expect(lines[4]).to match /rspec.yaml/
    expect(lines[5]).to match /Load Library.*.rb/
    expect(lines[6]).to match /Load Library.*.rb/
    expect(lines[7]).to match /Load Library.*.rb/
    expect(lines[8]).to match /Start Script/
    expect(lines[9]).to match /Logging Start/
    expect(lines[10]).to match /test_string/
    expect(lines[11]).to match /var1/
    expect(lines[12]).to match /var0/
    expect(lines[13]).to match /FATAL/

  end
end
