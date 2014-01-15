require 'simplecov'
SimpleCov.start

require 'tmpdir'
require 'rbatch/variables'

describe RBatch::Variables do

  before :all do
    @home = File.join(Dir.tmpdir, "rbatch_test_" + Time.now.strftime("%Y%m%d%H%M%S"))
  end

  before :each do
    ENV["RB_HOME"]=@home
    ENV["RB_VERBOSE"]="0"
  end

  it "default" do
    @vars = RBatch::Variables.new()
    expect(@vars[:journal_verbose]).to eq 0
    #expect(@vars[:host_name]).to eq ""
    #expect(@vars[:program_name]).to eq "rspec"
    #expect(@vars[:program_path]).to eq "rspec"
    expect(@vars[:program_base]).to eq "rspec"
    expect(@vars[:home_dir]).to eq @home
    expect(@vars[:log_dir]).to eq File.join(@home,"log")
    expect(@vars[:conf_dir]).to eq File.join(@home,"conf")
    expect(@vars[:lib_dir]).to eq File.join(@home,"lib")
    expect(@vars[:run_conf_path]).to eq File.join(@home,".rbatchrc")
    expect(@vars[:config_path]).to eq File.join(@home,"conf","rspec.yaml")
    expect(@vars[:common_config_path]).to eq File.join(@home,"conf","common.yaml")
    expect(@vars.run_conf[:log_dir]).to eq "<home>/log"
    expect(@vars.run_conf[:conf_dir]).to eq "<home>/conf"
    expect(@vars.run_conf[:lib_dir]).to eq "<home>/lib"
    expect(@vars.run_conf[:log_name]).to eq "<date>_<time>_<prog>.log"
    expect(@vars[:log_name]).to_not eq "<date>_<time>_<prog>.log"
  end 

  it "success when ENV Change" do
    ENV["RB_HOME"]="/var"
    ENV["RB_VERBOSE"]="3"

    @vars = RBatch::Variables.new()
    expect(@vars[:journal_verbose]).to eq 3
    expect(@vars[:home_dir]).to eq "/var"
    expect(@vars[:log_dir]).to eq File.join("/var","log")
  end 

  describe "merge!" do
    it "success" do
      @vars = RBatch::Variables.new()
      @vars.merge!({:log_name => "hoge"})
      expect(@vars[:log_name]).to eq "hoge"
    end
  end

  describe "run conf" do
    it "return runconf value via method missing" do
      @vars = RBatch::Variables.new()
      expect(@vars[:log_level]).to eq "info"
    end

    it "raise when key does not exist in run_conf" do
      @vars = RBatch::Variables.new()
      expect{@vars[:hoge]}.to raise_error RBatch::VariablesException
    end
  end
end
