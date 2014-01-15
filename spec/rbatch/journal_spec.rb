require 'simplecov'
SimpleCov.start

require 'rbatch/journal'

describe RBatch::Journal do
  it "default" do
    @j = RBatch::Journal.new
    expect(@j.journal_verbose) == 1
  end

  it "is passed argument" do
    @j = RBatch::Journal.new(2)
    expect(@j.journal_verbose) == 2
  end

  it "ENV is set" do
     ENV["RB_VERBOSE"] = "0"
    @j = RBatch::Journal.new
    expect(@j.journal_verbose) == 0
  end

  it "both argument and ENV are set" do
     ENV["RB_VERBOSE"] = "0"
    @j = RBatch::Journal.new(2)
    expect(@j.journal_verbose) == 2
  end
end

