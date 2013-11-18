require 'test/unit'
require 'rbatch'

class RuncherTest < Test::Unit::TestCase
  def setup
    @config_dir =  File.join(File.dirname(RBatch.program_name), "..", "conf")
    @config_file = File.join(@config_dir,"common.yaml")
    Dir::mkdir(@config_dir) if ! Dir.exists? @config_dir
  end

  def teardown
    File.delete @config_file if File.exist? @config_file
  end

  def test_require
  end

  def test_config
    open( @config_file  , "w" ){|f| f.write("key: value")}
    assert_equal "value",  RBatch.common_config["key"]
  end

  def test_read_error
    assert_raise(Errno::ENOENT){
      RBatch.common_config
    }
  end

  def test_double_read
    open( @config_file  , "w" ){|f| f.write("key: value")}
    assert_equal "value",  RBatch.common_config["key"]
    assert_equal "value",  RBatch.common_config["key"]
  end

  def test_not_exist_key
    open( @config_file  , "w" ){|f| f.write("key: value")}
    assert_raise(RBatch::CommonConfig::Exception){
      RBatch.common_config["not_exist"]
    }
  end
end
