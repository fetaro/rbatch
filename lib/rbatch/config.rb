require 'yaml'
require 'pathname'

module RBatch

  class Config
    # Config file path
    @path

    # Actual data
    @hash

    # @param [String] path Config file path
    def initialize(path)
      @path = path
      begin
        @hash = ConfigElement.new(YAML::load_file(@path))
      rescue Errno::ENOENT => e
        @hash = nil
      end
    end

    # Config value
    # @param [Object] key Config key.
    # @raise [RBatch::ConfigException]
    def[](key)
      if @hash.nil?
        raise RBatch::ConfigException, "Config file \"#{@path}\" does not exist"
      else
        @hash[key]
      end
    end

    # Config file path
    # @return [String]
    def path ; @path ; end

    # Config file exists or not
    # @return [Boolean]
    def exist? ; ! @hash.nil? ; end

    # @return [Hash]
    def to_h
      if @hash.nil?
        raise RBatch::ConfigException, "Config file \"#{@path}\" does not exist"
      else
        @hash
      end
    end

    # @return [String]
    def to_s
      if @hash.nil?
        raise RBatch::ConfigException, "Config file \"#{@path}\" does not exist"
      else
        @hash.to_s
      end
    end
  end

  class ConfigElement < Hash
    def initialize(hash)
      hash.each_key do |key|
        if hash[key].class == Hash
          self[key] = ConfigElement.new(hash[key])
        else
          self[key] = hash[key]
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

