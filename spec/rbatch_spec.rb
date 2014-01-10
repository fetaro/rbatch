require File.expand_path(File.join( File.dirname(__FILE__), 'spec_helper'))

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
    require 'rbatch'
    expect(RBatch.ctrl.home_dir).to eq ENV["RB_HOME"]
  end


end
