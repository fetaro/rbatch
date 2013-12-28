require 'tmpdir'
ENV["RB_VERBOSE"]="0"
ENV["RB_HOME"]=Dir.tmpdir

require 'rbatch'

describe RBatch::Config do
  before :all do
    @config_dir=File.join(Dir.tmpdir,"conf")
    @config_file = File.join(@config_dir , "rspec.yaml")
    Dir::mkdir @config_dir if ! Dir.exists? @config_dir
  end

  before :each do
  end

  after :each do
    FileUtils.rm @config_file if File.exists? @config_file
  end

  after :all do
  end

  it "read config" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    expect(RBatch.config["key"]).to eq "value"
  end

  it "raise error when config does not exist" do
    expect {
      RBatch.config
    }.to raise_error(Errno::ENOENT)
  end

  it "read config twice" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    expect(RBatch.config["key"]).to eq "value"
    expect(RBatch.config["key"]).to eq "value"
  end

  it "raise error when read value which key does not exist" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    expect {
      RBatch.config["not_exist"]
    }.to raise_error(RBatch::Config::Exception)
  end


end
