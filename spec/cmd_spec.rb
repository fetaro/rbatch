require File.expand_path(File.join( File.dirname(__FILE__), 'spec_helper'))

require 'rbatch'

describe RBatch::Cmd do
  before :each do
    RBatch.run_conf.reset
  end

  it "run command which status is 0" do
    result = RBatch::cmd "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 0;'"
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    expect(result.status).to eq 0
  end
  it "run command which status is 1" do
    result = RBatch::cmd "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'"
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    expect(result.status).to eq 1
  end
  it "raise error when command does not exist" do
    expect {
      RBatch::cmd "not_exist_command"
    }.to raise_error(Errno::ENOENT)
  end
  it "run command which stdout size is greater than 65534byte" do
    result = RBatch::cmd "ruby -e '100000.times{print 0}'"
    expect(result.stdout.chomp.size).to eq 100000
    expect(result.stderr.chomp).to eq ""
    expect(result.status).to eq 0
  end
  it "run command which stdout size is greater than 65534bytes with status 1" do
    result = RBatch::cmd "ruby -e '100000.times{print 0}; exit 1'"
    expect(result.stdout.chomp.size).to eq 100000
    expect(result.stderr.chomp).to eq ""
    expect(result.status).to eq 1
  end
  it "run command which status is grater than 256" do
    result = RBatch::cmd  "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 300;'"
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    case RUBY_PLATFORM
    when /mswin|mingw/
      expect(result.status).to eq 300
    when /cygwin|linux/
      # windos platform can not handle result code as modular 256
      expect(result.status).to eq 44
    end
  end
  it "run to_h method" do
    result = RBatch::cmd "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'"
    expect(result.to_h[:stdout]).to eq "1"
    expect(result.to_h[:stderr]).to eq "2"
    expect(result.to_h[:status]).to eq 1
  end
  it "run to_s method" do
    result = RBatch::cmd "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'"
    expect(result.to_s).to eq "{:cmd_str=>\"ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'\", :stdout=>\"1\", :stderr=>\"2\", :status=>1}"
  end
  it "raise error when command is nil" do
    expect {
      RBatch::Cmd.new(nil)
    }.to raise_error(RBatch::CmdException)
  end
  it "run RBatch::Cmd.new method" do
    result = RBatch::Cmd.new("ruby -e 'STDOUT.print 1; STDERR.print 2; exit 0;'").run
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    expect(result.status).to eq 0
  end


  describe "option by argument" do
    describe "timeout" do
      it "run successfuly when command is short time" do
        opt = {:timeout => 2}
        expect {
          RBatch::cmd("ruby -e 'sleep 1'",opt)
        }.to_not raise_error
      end
      it "raise timeout error when command is long time" do
        opt = {:timeout => 1}
        expect {
          RBatch::cmd("ruby -e 'sleep 2'",opt)
        }.to raise_error(RBatch::CmdException)
      end
    end
  end

  describe "option by argument" do
    describe "timeout" do
      it "run successfuly when command is short time" do
        opt = {:timeout => 2}
        expect {
          RBatch::cmd("ruby -e 'sleep 1'",opt)
        }.to_not raise_error
      end
      it "raise timeout error when command is long time" do
        opt = {:timeout => 1}
        expect {
          RBatch::cmd("ruby -e 'sleep 2'",opt)
        }.to raise_error(RBatch::CmdException)
      end
    end
  end

  describe "option by config" do
    before :all do
      @config_dir=File.join(ENV["RB_HOME"],"conf")
      @config_file = File.join(@config_dir , "rbatch.yaml")
      Dir::mkdir @config_dir if ! Dir.exists? @config_dir
    end
    describe "raise" do
      before :each do
        RBatch.run_conf[:cmd_raise] = true
      end
      it "raise error when command status is not 0" do
        expect {
          RBatch::cmd "ruby -e 'exit 1;'"
        }.to raise_error(RBatch::CmdException)
      end
    end
  end
end
