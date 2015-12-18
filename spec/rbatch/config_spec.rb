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

  it "read yaml format" do
    open( @path  , "w" ){|f| f.write("key: <%= \"hoge\" %>")}
    expect(RBatch::Config.new(@path,false)["key"]).to eq "<%= \"hoge\" %>"
  end

  it "read erb format" do
    open( @path  , "w" ){|f| f.write("key: <%= \"hoge\" %>" )}
    expect(RBatch::Config.new(@path,true)["key"]).to eq "hoge"
  end

end

describe "RBatch::Config.parse" do
  it "parses hash" do
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
    ce = RBatch::Config.parse(hash)
    expect(ce["a"]).to eq "av"
    expect(ce["b"].class).to eq RBatch::ConfigElementHash
    expect(ce["b"]["c"]).to eq "cv"
    expect(ce["b"]["d"].class).to eq RBatch::ConfigElementHash
    expect(ce["b"]["d"]["e"]).to eq "ev"
    expect(ce["b"]["d"]["f"][1]).to eq 2
    expect { ce["noexist"] }.to raise_error(RBatch::ConfigException)
    expect { ce["noexist"]["noexist"] }.to raise_error(RBatch::ConfigException)
    expect { ce["b"]["noexist"] }.to raise_error(RBatch::ConfigException)
    expect { ce["b"]["d"]["noexist"] }.to raise_error(RBatch::ConfigException)
  end

  it "parses array" do
    array = [
      "a",
      [ "b", "c" ],
      { "d" => "dv" , "e" => "ev" },
      [ "f",["g","h","i"]]
    ]
    ce = RBatch::Config.parse(array)
    expect(ce.class).to eq RBatch::ConfigElementArray
    expect(ce[0]).to eq "a"
    expect(ce[1].class).to eq RBatch::ConfigElementArray
    expect(ce[1][0]).to eq "b"
    expect(ce[1][1]).to eq "c"
    expect(ce[2].class).to eq RBatch::ConfigElementHash
    expect(ce[2]["d"]).to eq "dv"
    expect { ce[2]["z"] }.to raise_error(RBatch::ConfigException)
    expect(ce[3][1][1]).to eq "h"
  end
end
