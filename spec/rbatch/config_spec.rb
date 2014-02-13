require 'simplecov'
SimpleCov.start

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

describe RBatch::ConfigElement do
  it "" do
    hash = {
      "a" => "av" ,
      "b" => {
        "c" => "cv",
        "d" => {
          "e" => "ev",
          "f" => [1,2,3]
        }
      }
    }
    ce = RBatch::ConfigElement.new(hash)
    expect(ce["a"]).to eq "av"
    expect(ce["b"].class).to eq RBatch::ConfigElement
    expect(ce["b"]["c"]).to eq "cv"
    expect(ce["b"]["d"].class).to eq RBatch::ConfigElement
    expect(ce["b"]["d"]["e"]).to eq "ev"
    expect(ce["b"]["d"]["f"][1]).to eq 2
    expect { ce["noexist"] }.to raise_error(RBatch::ConfigException)
    expect { ce["noexist"]["noexist"] }.to raise_error(RBatch::ConfigException)
    expect { ce["b"]["noexist"] }.to raise_error(RBatch::ConfigException)
    expect { ce["b"]["d"]["noexist"] }.to raise_error(RBatch::ConfigException)
  end
end
