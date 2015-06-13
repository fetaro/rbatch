require 'simplecov'
SimpleCov.start

require 'tmpdir'
require 'rbatch/controller'
describe RBatch::Controller do

  before :all do
  end

  after :each do
  end

  it "can reads yaml config" do
    @rand = "rbatch_test_" + rand.to_s
    @home = File.join(Dir.tmpdir, @rand)
    @log_dir = File.join(@home,"log")
    @conf_dir = File.join(@home,"conf")
    ENV["RB_HOME"]=@home

    Dir.mkdir(@home)
    Dir.mkdir(@conf_dir)
    open( File.join(@conf_dir,"rspec.yaml") , "a" ){|f|
      f.write("key1 : <%= \"hoge1\" %>")
    }

    open( File.join(@conf_dir,"common.yaml") , "a" ){|f|
      f.write("key2 : <%= \"hoge2\" %>")
    }
    $stdout = File.open("/tmp/rbatch.std.out", "w")  # change stdout
    ctrl = RBatch::Controller.new()
    $stdout = STDOUT# restore stdout

    expect(ctrl.config["key1"]).to eq "<%= \"hoge1\" %>" 
    expect(ctrl.common_config["key2"]).to eq "<%= \"hoge2\" %>" 
  end

  it "reads erb config" do
    @rand = "rbatch_test_" + rand.to_s
    @home = File.join(Dir.tmpdir, @rand)
    @log_dir = File.join(@home,"log")
    @conf_dir = File.join(@home,"conf")
    ENV["RB_HOME"]=@home

    Dir.mkdir(@home)
    Dir.mkdir(@conf_dir)
    open( File.join(@conf_dir,"rspec.yaml.erb") , "a" ){|f|
      f.write("key1 : <%= \"hoge1\" %>")
    }

    open( File.join(@conf_dir,"common.yaml.erb") , "a" ){|f|
      f.write("key2 : <%= \"hoge2\" %>")
    }
    $stdout = File.open("/tmp/rbatch.std.out", "w")  # change stdout
    ctrl = RBatch::Controller.new()
    $stdout = STDOUT# restore stdout

    expect(ctrl.config["key1"]).to eq "hoge1" 
    expect(ctrl.common_config["key2"]).to eq "hoge2" 
  end

  it "reads yaml config when both yaml and erb exist" do
    @rand = "rbatch_test_" + rand.to_s
    @home = File.join(Dir.tmpdir, @rand)
    @log_dir = File.join(@home,"log")
    @conf_dir = File.join(@home,"conf")
    ENV["RB_HOME"]=@home

    Dir.mkdir(@home)
    Dir.mkdir(@conf_dir)
    open( File.join(@conf_dir,"rspec.yaml") , "a" ){|f|
      f.write("key1 : <%= \"hoge1\" %>")
    }
    open( File.join(@conf_dir,"rspec.yaml.erb") , "a" ){|f|
      f.write("key1 : <%= \"hoge1\" %>")
    }

    open( File.join(@conf_dir,"common.yaml") , "a" ){|f|
      f.write("key2 : <%= \"hoge2\" %>")
    }
    open( File.join(@conf_dir,"common.yaml.erb") , "a" ){|f|
      f.write("key2 : <%= \"hoge2\" %>")
    }
    $stdout = File.open("/tmp/rbatch.std.out", "w")  # change stdout
    ctrl = RBatch::Controller.new()
    $stdout = STDOUT# restore stdout

    expect(ctrl.config["key1"]).to eq "<%= \"hoge1\" %>" 
    expect(ctrl.common_config["key2"]).to eq "<%= \"hoge2\" %>" 
  end


end
