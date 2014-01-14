require 'tmpdir'
require 'rbatch/config'

describe RBatch::Config do
  before :all do
  end

  before :each do
    @path = File.join(Dir.tmpdir , rand.to_s)
  end
  
  after :each do
    FileUtils.rm @path if File.exists? @path
  end
  
  it "read" do
    open( @path  , "w" ){|f| f.write("key: value")}
    expect(RBatch::Config.new(@path)["key"]).to eq "value"
  end
  
  it "key is Symbol" do
    open( @path  , "w" ){|f| f.write(":key: value")}
    expect(RBatch::Config.new(@path)[:key]).to eq "value"
  end
  
  it "raise error when config does not exist" do
    expect {
      RBatch::Config.new(@path)["hoge"]
    }.to raise_error(RBatch::ConfigException)
    expect {
      RBatch::Config.new(@path).to_h
    }.to raise_error(RBatch::ConfigException)
    expect {
      RBatch::Config.new(@path).to_s
    }.to raise_error(RBatch::ConfigException)
  end
  
  it "read config twice" do
    open( @path  , "w" ){|f| f.write("key: value")}
    expect(RBatch::Config.new(@path)["key"]).to eq "value"
    expect(RBatch::Config.new(@path)["key"]).to eq "value"
  end
  
  it "raise error when read value which key does not exist" do
    open( @path  , "w" ){|f| f.write("key: value")}
    expect {
      RBatch::Config.new(@path)["not_exist"]
    }.to raise_error(RBatch::ConfigException)
  end
  
  it "raise error when read value which key mistake String for Symbol" do
    open( @path  , "w" ){|f| f.write("key: value")}
    expect {
      RBatch::Config.new(@path)[:key]
    }.to raise_error(RBatch::ConfigException)
  end
  
  it "raise error when read value which key mistake Symbol for String" do
    open( @path  , "w" ){|f| f.write(":key: value")}
    expect {
      RBatch::Config.new(@path)["key"]
    }.to raise_error(RBatch::ConfigException)
  end
end
