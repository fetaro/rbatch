require 'tmpdir'
require 'rbatch/run_conf'

describe RBatch::RunConf do
  before :all do
    @config = File.join(Dir.tmpdir,"run_conf_test.yaml")
  end

  before :each do
    FileUtils.rm @config if File.exists? @config
    open( @config  , "w" ){|f| f.write("")}
    @rc = RBatch::RunConf.new(@config)
  end

  after :each do
  end

  after :all do
  end

  it "is default when run_conf is empty" do
    expect(@rc[:log_dir]).to eq "log"
  end

  it "is default when run_conf does not exist" do
    FileUtils.rm @config
    tmp = RBatch::RunConf.new(@config)
    expect(tmp[:log_dir]).to eq "log"
  end

  it "raise when key does not exist" do
    expect{@rc[:not_exist_key]}.to raise_error(RBatch::RunConf::Exception)
  end

  it "read run conf" do
    open( @config  , "w" ){|f| f.write("log_dir: hoge")}
    tmp = RBatch::RunConf.new(@config)
    expect(tmp[:log_dir]).to eq "hoge"
  end

  it "raise when run_conf has unreserved key" do
    open( @config  , "w" ){|f| f.write("unreserved: hoge")}
    expect{tmp = RBatch::RunConf.new(@config)}.to raise_error(RBatch::RunConf::Exception)
  end

  describe "[]= method" do
    it "success" do
      expect(@rc[:log_dir]).to eq "log"
      @rc[:log_dir] = "hoge"
      expect(@rc[:log_dir]).to eq "hoge"
    end

    it "raise when set unreserved key" do
      expect{@rc[:unreservied] = "hoge"}.to raise_error(RBatch::RunConf::Exception)
    end
  end
  
  describe "merge! method" do
    it "success" do
      opt={ :log_dir => "bar"}
      @rc.merge!(opt)
      expect(@rc[:log_dir]).to eq "bar"
    end

    it "raise when key does not exist" do
      opt={ :unreserved => "bar"}
      expect{@rc.merge!(opt)}.to raise_error(RBatch::RunConf::Exception)
    end
  end

  describe "merge method" do
    it "success" do
      opt={ :log_dir => "bar"}
      tmp = @rc.merge(opt)
      expect(@rc[:log_dir]).to eq "log"
      expect(tmp[:log_dir]).to eq "bar"
    end

    it "raise when key does not exist" do
      opt={ :unreserved => "bar"}
      expect{@rc.merge(opt)}.to raise_error(RBatch::RunConf::Exception)
    end
  end
end
