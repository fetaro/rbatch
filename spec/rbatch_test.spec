require 'rbatch'

describe RBatch do
  before :all do
    RBatch.home_dir=Dir.tmpdir
    @config_dir=File.join(RBatch.home_dir,"conf")
    @config_file = File.join(@config_dir , "rbatch.yaml")
    Dir::mkdir @config_dir if ! Dir.exists? @config_dir
  end

  before :each do
  end

  it "makes lock file when forbid_double_run is enable" do
    open( @config_file  , "w" ){|f| f.write("forbid_double_run: true")}
  end

  after :each do
    FileUtils.rm @config_file if File.exists? @config_file
  end

  after :all do
  end

end
