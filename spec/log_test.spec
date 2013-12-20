require 'tmpdir'
ENV["RB_HOME"]=Dir.tmpdir

require 'rbatch'

describe RBatch::Log do

  before :all do
    @dir = RBatch.log_dir
    Dir::mkdir(@dir)if ! Dir.exists? @dir

    # set quiet option
    confstr = "log_quiet: true\n"
    open( RBatch.rbatch_config_path  , "w" ){|f| f.write(confstr)}
    RBatch.load_rbatch_config
  end

  after :each do
    Dir::foreach(@dir) do |f|
      File::delete(File.join(@dir , f)) if ! (/\.+$/ =~ f)
    end
  end

  it "output log" do
    RBatch::Log.new do | log |
      log.info("test_log")
    end
    Dir::foreach(@dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@dir , f)) {|f|
          expect(f.read).to match /test_log/
        }
      end
    end
  end

  it "raise error when log dir does not exist" do
    Dir::rmdir(@dir)
    expect{
      RBatch::Log.new {|log|}
    }.to raise_error(Errno::ENOENT)
    Dir::mkdir(@dir)
  end

  describe "option by argument" do
    it "change log name" do
      RBatch::Log.new({:name => "name1.log" }) do | log |
        log.info("test_change_name_by_opt")
      end
      File::open(File.join(@dir , "name1.log")) {|f|
        expect(f.read).to match /test_change_name_by_opt/
      }
    end

    it "change log name with <prog><date>" do
      RBatch::Log.new({:name => "<prog><date>name.log" }) do | log |
        log.info("test_change_name_by_opt2")
      end
      File::open(File.join(@dir ,  "rspec" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
        expect(f.read).to match /test_change_name_by_opt2/
      }
    end

   it "change log name with include hifun" do
      RBatch::Log.new({:name => "<prog>-<date>-name.log" }) do | log |
        log.info("test_change_name_by_opt2")
      end
      File::open(File.join(@dir ,  "rspec-" + Time.now.strftime("%Y%m%d") + "-name.log")) {|f|
        expect(f.read).to match /test_change_name_by_opt2/
      }
  end

  end
end
