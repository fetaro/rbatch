require 'tmpdir'

describe "RBatch" do
  before :all do
  end

  before :each do
  end

  after :each do
  end

  after :all do
  end

  it "RB_HOME should be home_dir" do
    @dir = Dir.tmpdir
    ENV["RB_HOME"]=@dir
    require 'rbatch'
    expect(RBatch.home_dir).to eq @dir
  end


end
