require 'test/unit'
class RuncherTest < Test::Unit::TestCase
  def setup
    @config_dir =  "./test/config/"
    @config_file = @config_dir + "test_auto_config.yaml"
    Dir::mkdir("./test/config/") if ! Dir.exists? @config_dir
  end

  def teardown
    File.delete @config_file if File.exist? @config_file
  end

  def test_require
    require './lib/rbatch/auto_config'
  end

  def test_read_config
    require './lib/rbatch/auto_config'
    open( @config_file  , "w" ){|f| f.write("key: value")}
    assert_equal "value",  RBatch.read_config["key"]
  end

  def test_read_error
    require './lib/rbatch/auto_config'
    assert_raise(Errno::ENOENT){
      RBatch.read_config
    }
  end

  def test_double_read
    require './lib/rbatch/auto_config'
    open( @config_file  , "w" ){|f| f.write("key: value")}
    assert_equal "value",  RBatch.read_config["key"]
    assert_equal "value",  RBatch.read_config["key"]
  end
end
