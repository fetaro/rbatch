require 'yaml'
require 'pathname'

module RBatch

  module_function

  # Alias of RBatch::CommonConfig.new
  def common_config ; CommonConfig.new end

  # Common-config Reader
  #
  # Read common config file and return hash opject. If the key does not exist in config file, raise RBatch::CommonConfig::Exception.
  #
  # Default common config file path is "${RB_HOME}/conf/common.yaml"
  # ==== Sample
  # config : ${RB_HOME}/conf/common.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # script : ${RB_HOME}/bin/sample.rb
  #  require 'rbatch'
  #  p RBatch::common_config
  #  => {"key" => "value", "array" => ["item1", "item2", "item3"]}
  class CommonConfig
    @path
    @config
    def initialize
      file = RBatch.run_conf[:common_conf_name]
      @path = File.join(RBatch.run_conf[:conf_dir].gsub("<home>",RBatch.home_dir),file)
      @config = YAML::load_file(@path)
    end
    def[](key)
      raise RBatch::CommonConfig::Exception, "Value of key=\"#{key}\" is nil" if @config[key].nil?
      @config[key]
    end
    def path ; @path ; end
    def to_s ; @config.to_s ;end
  end

  class RBatch::CommonConfig::Exception < Exception; end
end

