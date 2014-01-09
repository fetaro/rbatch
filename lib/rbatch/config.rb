require 'yaml'
require 'pathname'

module RBatch

  module_function

  # Alias of RBatch::Config.new
  def config ; Config.new end

  # Config Reader
  #
  # Read config file and return hash opject. If the key does not exist in config file, raise RBatch::Config::Exception.
  # 
  # Default config file path is "${RB_HOME}/conf/(program base name).yaml"
  # ==== Sample
  # config : ${RB_HOME}/conf/sample2.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # script : ${RB_HOME}/bin/sample2.rb
  #  require 'rbatch'
  #  p RBatch::Config.new
  #  # or  p RBatch::config
  #  => {"key" => "value", "array" => ["item1", "item2", "item3"]}
  class Config
    @path
    @config
    def initialize
      file = Pathname(File.basename(RBatch.program_name)).sub_ext(".yaml").to_s
      @path = File.join(RBatch.conf_dir,file)
      @config = YAML::load_file(@path)
    end
    def[](key)
      if @config[key].nil?
        if key.class == Symbol
          raise RBatch::Config::Exception, "Value of key(:#{key} (Symbol)) is nil. By any chance, dou you mistake key class Symbol for String?"
        elsif key.class == String
          raise RBatch::Config::Exception, "Value of key(\"#{key}\" (String)) is nil"
        else
          raise RBatch::Config::Exception, "Value of key(#{key}) is nil."
        end
      else
        @config[key]
      end
    end
    def path ; @path ; end
    def to_s ; @config.to_s ;end
  end

  class RBatch::Config::Exception < Exception; end
end

