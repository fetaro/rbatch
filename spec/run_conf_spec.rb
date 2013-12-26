require 'tmpdir'
require 'rbatch/run_conf'

describe RBatch::RunConf do
  before :all do
    @home = Dir.tmpdir
    @config = File.join(@home,"run_conf_test.yaml")
  end

  before :each do
    FileUtils.rm @config if File.exists? @config
    open( @config  , "w" ){|f| f.write("")}
    @rc = RBatch::RunConf.new(@config,@home)
  end

  after :each do
  end

  after :all do
  end

  it "is default when run_conf is empty" do
    expect(@rc[:log_level]).to eq "info"
  end

  it "is default when run_conf does not exist" do
    FileUtils.rm @config
    tmp = RBatch::RunConf.new(@config,@home)
    expect(tmp[:log_level]).to eq "info"
  end

  it "raise when key does not exist" do
    expect{@rc[:not_exist_key]}.to raise_error(RBatch::RunConf::Exception)
  end

  it "read run conf" do
    open( @config  , "w" ){|f| f.write("log_level: hoge")}
    tmp = RBatch::RunConf.new(@config,@home)
    expect(tmp[:log_level]).to eq "hoge"
  end

  it "raise when run_conf has unreserved key" do
    open( @config  , "w" ){|f| f.write("unreserved: hoge")}
    expect{tmp = RBatch::RunConf.new(@config,@home)}.to raise_error(RBatch::RunConf::Exception)
  end

  describe "[]= method" do
    it "success" do
      expect(@rc[:log_level]).to eq "info"
      @rc[:log_level] = "hoge"
      expect(@rc[:log_level]).to eq "hoge"
    end

    it "raise when set unreserved key" do
      expect{@rc[:unreservied] = "hoge"}.to raise_error(RBatch::RunConf::Exception)
    end
  end
  
  describe "merge! method" do
    it "success" do
      opt={ :log_level => "error"}
      @rc.merge!(opt)
      expect(@rc[:log_level]).to eq "error"
    end

    it "raise when key does not exist" do
      opt={ :unreserved => "error"}
      expect{@rc.merge!(opt)}.to raise_error(RBatch::RunConf::Exception)
    end
  end

  describe "merge method" do
    it "success" do
      opt={ :log_level => "error"}
      tmp = @rc.merge(opt)
      expect(@rc[:log_level]).to eq "info"
      expect(tmp[:log_level]).to eq "error"
    end

    it "raise when key does not exist" do
      opt={ :unreserved => "error"}
      expect{@rc.merge(opt)}.to raise_error(RBatch::RunConf::Exception)
    end
  end
end
