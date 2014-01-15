require 'simplecov'
SimpleCov.start

require 'tmpdir'
require 'rbatch/controller'
describe RBatch::Controller do

  before :all do
    @home = File.join(Dir.tmpdir, "rbatch_test_" + rand.to_s)
  end

  after :each do
  end

  it "success" do
    RBatch::Variables.new()
  end
end
