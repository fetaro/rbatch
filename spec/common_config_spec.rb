require 'tmpdir'
ENV["RB_HOME"]=Dir.tmpdir

require 'rbatch'

describe RBatch::CommonConfig do
  before :all do
    @config_dir=File.join(Dir.tmpdir,"conf")
    @config_file = File.join(@config_dir , "common.yaml")
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
    expect(RBatch.common_config["key"]).to eq "value"
  end

  it "raise error when config does not exist" do
    expect {
      RBatch.common_config
    }.to raise_error(Errno::ENOENT)
  end

  it "read config twice" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    expect(RBatch.common_config["key"]).to eq "value"
    expect(RBatch.common_config["key"]).to eq "value"
  end

  it "raise error when read value which key does not exist" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    expect {
      RBatch.common_config["not_exist"]
    }.to raise_error(RBatch::CommonConfig::Exception)
  end

  it "success when common_conf_name changed" do
    conf=File.join(Dir.tmpdir,"global.yaml")
    open( conf  , "w" ){|f| f.write("key4: value4")}
    RBatch.run_conf[:common_conf_name]="global.yaml"
    expect(RBatch.common_config["key4"]).to eq "value4"
  end
end
