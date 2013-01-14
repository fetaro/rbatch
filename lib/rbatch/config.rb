require 'yaml'
require 'pathname'

module RBatch

  module_function

  # Alias of RBatch::Config.new
  def config ; Config.new end

  # Read config file and return hash opject.
  # 
  # Default config file path is "../conf/(Program Base name).yaml"
  # ==== Sample
  # config : ./conf/sample2.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # script : ./bin/sample2.rb
  #  require 'rbatch'
  #  p RBatch::Config.new
  #  # or  p RBatch::config
  #  => {"key" => "value", "array" => ["item1", "item2", "item3"]}
  class Config
    @path
    @config
    def initialize
      file = Pathname(File.basename(RBatch.program_name)).sub_ext(".yaml").to_s
      dir = File.join(File.join(File.dirname(RBatch.program_name),".."),"conf")
      @path = File.join(dir,file)
      @config = YAML::load_file(@path)
    end
    def[](key)
      raise RBatch::Config::Exception, "Value of key=\"#{key}\" is nil" if @config[key].nil?
      @config[key]
    end
    def path ; @path ; end
    def to_s ; @config.to_s ;end
  end

  class RBatch::Config::Exception < Exception; end
end

