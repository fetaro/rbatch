require File.expand_path(File.join( File.dirname(__FILE__), 'spec_helper'))

require 'rbatch'

describe RBatch::Config do
  before :all do
    @config_dir=File.join(ENV["RB_HOME"],"conf")
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
    RBatch.init
    expect(RBatch.common_config["key"]).to eq "value"
  end

  it "read config. Key is Symbol" do
    open( @config_file  , "w" ){|f| f.write(":key: value")}
    RBatch.init
    expect(RBatch.common_config[:key]).to eq "value"
  end

  it "raise error when config does not exist" do
    RBatch.init
    expect {
      RBatch.common_config["hoge"]
    }.to raise_error(RBatch::Config::Exception)
    expect {
      RBatch.common_config.to_h
    }.to raise_error(RBatch::Config::Exception)
    expect {
      RBatch.common_config.to_s
    }.to raise_error(RBatch::Config::Exception)
  end

  it "read config twice" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    RBatch.init
    expect(RBatch.common_config["key"]).to eq "value"
    expect(RBatch.common_config["key"]).to eq "value"
  end

  it "raise error when read value which key does not exist" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    RBatch.init
    expect {
      RBatch.common_config["not_exist"]
    }.to raise_error(RBatch::Config::Exception)
  end

  it "raise error when read value which key mistake String for Symbol" do
    open( @config_file  , "w" ){|f| f.write(":key: value")}
    RBatch.init
    expect {
      RBatch.common_config["key"]
    }.to raise_error(RBatch::Config::Exception)
  end

  it "raise error when read value which key mistake Symbol for String" do
    open( @config_file  , "w" ){|f| f.write("key: value")}
    RBatch.init
    expect {
      RBatch.common_config[:key]
    }.to raise_error(RBatch::Config::Exception)
  end

  it "success when common_conf_name changed" do
    conf=File.join(RBatch.ctrl.conf_dir,"global.yaml")
    open( conf  , "w" ){|f| f.write("key4: value4")}
    open( RBatch.run_conf_path  , "w" ){|f| f.write("common_conf_name: global.yaml")}
    RBatch.init
    expect(RBatch.common_config["key4"]).to eq "value4"
  end
end
