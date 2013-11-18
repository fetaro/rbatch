require 'yaml'
require 'pathname'

module RBatch

  module_function

  # Alias of RBatch::CommonConfig.new
  def common_config ; CommonConfig.new end

  # Read common config file and return hash opject.
  #
  # Default common config file path is "../conf/common.yaml"
  # ==== Sample
  # config : ./conf/common.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # script : ./bin/sample.rb
  #  require 'rbatch'
  #  p RBatch::common_config
  #  => {"key" => "value", "array" => ["item1", "item2", "item3"]}
  class CommonConfig
    @path
    @config
    def initialize
      file = "common.yaml"
      dir = File.join(File.join(File.dirname(RBatch.program_name),".."),"conf")
      @path = File.join(dir,file)
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

