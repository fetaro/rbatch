require 'simplecov'
SimpleCov.start

require 'rbatch/variables'
require 'rbatch/cmd'

describe RBatch::Cmd do
  before :each do
    @def_vars = RBatch::Variables.new()
    RBatch::Cmd.def_vars = @def_vars
  end

  it "run command which status is 0" do
    result = RBatch::Cmd.new("ruby -e 'STDOUT.print 1; STDERR.print 2; exit 0;'").run
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    expect(result.status).to eq 0
  end
  it "run command which status is 1" do
    result = RBatch::Cmd.new("ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'").run
    expect(result.stdout.chomp).to eq "1"
    expect(result.stderr.chomp).to eq "2"
    expect(result.status).to eq 1
  end
  it "raise error when command does not exist" do
    expect {
      RBatch::Cmd.new("not_exist_command").run
    }.to raise_error(Errno::ENOENT)
  end
  it "run command which stdout size is greater than 65534byte" do
    result = RBatch::Cmd.new("ruby -e '100000.times{print 0}'").run
    expect(result.stdout.chomp.size).to eq 100000
    expect(result.stderr.chomp).to eq ""
    expect(result.status).to eq 0
  end
  it "run command which stdout size is greater than 65534bytes with status 1" do
    result = RBatch::Cmd.new("ruby -e '100000.times{print 0}; exit 1'").run
    expect(result.stdout.chomp.size).to eq 100000
    expect(result.stderr.chomp).to eq ""
    expect(result.status).to eq 1
  end
  it "run command which status is grater than 256" do
    result = RBatch::Cmd.new( "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 300;'").run
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
    result = RBatch::Cmd.new("ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'").run
    expect(result.to_h[:stdout]).to eq "1"
    expect(result.to_h[:stderr]).to eq "2"
    expect(result.to_h[:status]).to eq 1
  end
  it "run to_s method" do
    result = RBatch::Cmd.new("ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'").run
    expect(result.to_s).to eq "{:cmd_str=>\"ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'\", :stdout=>\"1\", :stderr=>\"2\", :status=>1}"
  end
  it "raise error when command is nil" do
    expect {
      RBatch::Cmd.new(nil)
    }.to raise_error(RBatch::CmdException)
  end

  describe "option by argument" do
    describe "raise" do
      it "raise error when command status is not 0" do
        opt = {:raise => true}
        expect {
          RBatch::Cmd.new("ruby -e 'exit 1;'",opt).run
        }.to raise_error(RBatch::CmdException)
      end
    end
    describe "timeout" do
      it "run successfuly when command is short time" do
        opt = {:timeout => 2}
        expect {
          RBatch::Cmd.new("ruby -e 'sleep 1'",opt).run
        }.to_not raise_error
      end
      it "raise timeout error when command is long time" do
        opt = {:timeout => 1}
        expect {
          RBatch::Cmd.new("ruby -e 'sleep 2'",opt).run
        }.to raise_error(RBatch::CmdException)
      end
    end
  end

  describe "option by run_conf" do
    describe "raise" do
      it "raise error when command status is not 0" do
        @def_vars.merge!({:cmd_raise => true})
        RBatch::Cmd.def_vars = @def_vars
        expect {
          RBatch::Cmd.new("ruby -e 'exit 1;'").run
        }.to raise_error(RBatch::CmdException)
      end
    end
    describe "timeout" do
      it "run successfuly when command is short time" do
        @def_vars.merge!({:cmd_timeout => 2})
        RBatch::Cmd.def_vars = @def_vars
        expect {
          RBatch::Cmd.new("ruby -e 'sleep 1'").run
        }.to_not raise_error
      end
      it "raise timeout error when command is long time" do
        @def_vars.merge!({:cmd_timeout => 1})
        RBatch::Cmd.def_vars = @def_vars
        expect {
          RBatch::Cmd.new("ruby -e 'sleep 2'").run
        }.to raise_error(RBatch::CmdException)
      end
    end
  end
end
