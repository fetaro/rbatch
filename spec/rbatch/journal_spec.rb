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
end

