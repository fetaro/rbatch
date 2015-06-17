require 'yaml'
require 'pathname'
require 'erb'
module RBatch

  class Config
    # Config file path
    @path

    # Actual data
    @element

    # @param [String] path Config file path
    def initialize(path,is_erb = false)
      @path = path
      begin
        if is_erb
          @element = Config.parse(YAML::load(ERB.new(IO.read(@path)).result))
        else
          @element = Config.parse(YAML::load_file(@path))
        end
      rescue Errno::ENOENT => e
        @element = nil
      end
    end

    # Config value
    # @param [Object] key Config key.
    # @raise [RBatch::ConfigException]
    def[](key)
      if @element.nil?
        raise RBatch::ConfigException, "Config file \"#{@path}\" does not exist"
      else
        @element[key]
      end
    end

    # Config file path
    # @return [String]
    def path ; @path ; end

    # Config file exists or not
    # @return [Boolean]
    def exist? ; ! @element.nil? ; end

    # @return [Hash]
    def to_h
      if @element.nil?
        raise RBatch::ConfigException, "Config file \"#{@path}\" does not exist"
      else
        @element
      end
    end

    # @return [String]
    def to_s
      if @element.nil?
        raise RBatch::ConfigException, "Config file \"#{@path}\" does not exist"
      else
        @element.to_s
      end
    end

    # @return ConfigElementArray or ConfigElementHash
    def Config.parse(yaml)
      if yaml.class == Hash
        return ConfigElementHash.new(yaml)
      elsif yaml.class == Array
        return ConfigElementArray.new(yaml)
      else
        return yaml
      end
    end
  end
  
  class ConfigElementArray < Array
    def initialize(array)
      array.each_with_index do |item,index|
        self[index] = Config.parse(item)
      end
    end
  end
  
  class ConfigElementHash < Hash
    def initialize(hash)
      if hash
        hash.each_key do |key|
          self[key] = Config.parse(hash[key])
        end
      end
    end

    def[](key)
      if self.has_key?(key)
        super
      else
        if key.class == Symbol
          raise RBatch::ConfigException, "Value of key(:#{key} (Symbol)) does not exist. By any chance, dou you mistake key class Symbol for String?"
        elsif key.class == String
          raise RBatch::ConfigException, "Value of key(\"#{key}\" (String)) does not exist"
        else
          raise RBatch::ConfigException, "Value of key(#{key}) does not exist."
        end
        raise
      end
    end
  end

  class RBatch::ConfigException < StandardError ; end
end

