require 'simplecov'
SimpleCov.start

require 'rbatch/double_run_checker'

describe RBatch::DoubleRunChecker do
  it "check" do
    expect{RBatch::DoubleRunChecker.check("hoge")}.to_not raise_error
    RBatch::DoubleRunChecker.make_lock_file("hoge")
    expect{RBatch::DoubleRunChecker.check("hoge")}.to raise_error(RBatch::DoubleRunCheckException)
    expect{RBatch::DoubleRunChecker.check("bar")}.to_not raise_error
  end
end
