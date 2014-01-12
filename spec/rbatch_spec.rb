require 'tmpdir'

describe "RBatch" do
  before :all do
    @home = File.join(Dir.tmpdir, "rbatch_test_" + rand.to_s)
    @log_dir = File.join(@home,"log")
    @conf_dir = File.join(@home,"conf")
    ENV["RB_HOME"]=@home
    ENV["RB_VERBOSE"]="0"

    Dir.mkdir(@home)
    Dir.mkdir(@log_dir)
    Dir.mkdir(@conf_dir)
    open( File.join(@home,".rbatchrc") , "a" ){|f|
      f.write("")
    }

    open( File.join(@conf_dir,"rspec.yaml") , "a" ){|f|
      f.write("key1 : value1")
    }

    open( File.join(@conf_dir,"common.yaml") , "a" ){|f|
      f.write("key2 : value2")
    }

  end

  after :all do
    FileUtils.rm_rf(@home)
  end

  it "success" do
    require 'rbatch'

    result = RBatch.cmd("ruby -e 'STDOUT.print 1; STDERR.print 2; exit 0;'")
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    expect(result.status).to eq 0
    expect{
      RBatch.cmd("ruby -e 'exit 1;'",{:raise => true})
    }.to raise_error(RBatch::Cmd::Exception)


    expect(RBatch.config["key1"]).to eq "value1"
    expect{ RBatch.config["noexist"] }.to raise_error RBatch::Config::Exception

    expect(RBatch.common_config["key2"]).to eq "value2"
    expect{ RBatch.common_config["noexist"] }.to raise_error RBatch::Config::Exception

    RBatch.log do |log|
      log.info("test_string")
    end
    Dir::foreach(RBatch.vars[:log_dir]) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(RBatch.vars[:log_dir] , f)) {|f|
          expect(f.read).to match /test_string/
        }
      end
    end
  end
end
