require 'yaml'
require 'pathname'

module RBatch

  module_function
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
    @hash
    def initialize
      file = RBatch.run_conf[:common_conf_name]
      @path = File.join(RBatch.conf_dir,file)
      begin
        @hash = YAML::load_file(@path)
      rescue Errno::ENOENT => e
        @hash = nil
      end
    end
    def[](key)
      if @hash.nil?
        raise RBatch::CommonConfig::Exception, "Common Config file \"#{@path}\" does not exist"
      end
      if @hash[key].nil?
        if key.class == Symbol
          raise RBatch::CommonConfig::Exception, "Value of key(:#{key} (Symbol)) is nil. By any chance, dou you mistake key class Symbol for String?"
        elsif key.class == String
          raise RBatch::CommonConfig::Exception, "Value of key(\"#{key}\" (String)) is nil"
        else
          raise RBatch::CommonConfig::Exception, "Value of key(#{key}) is nil"
        end
      else
        @hash[key]
      end
    end
    def path ; @path ; end
    def exist? ; ! @hash.nil? ; end
    def to_h
      if @hash.nil?
        raise RBatch::CommonConfig::Exception, "Common Config file \"#{@path}\" does not exist"
      else
        @hash
      end
    end
    def to_s
      if @hash.nil?
        raise RBatch::CommonConfig::Exception, "Common Config file \"#{@path}\" does not exist"
      else
        @hash.to_s
      end
    end
  end

  class RBatch::CommonConfig::Exception < Exception; end
end

