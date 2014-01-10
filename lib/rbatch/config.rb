require 'yaml'
require 'pathname'

module RBatch

  class Config
    @path
    @hash
    def initialize(path)
      @path = path
      begin
        @hash = YAML::load_file(@path)
      rescue Errno::ENOENT => e
        @hash = nil
      end
    end
    def[](key)
      if @hash.nil?
        raise RBatch::Config::Exception, "Config file \"#{@path}\" does not exist"
      end
      if @hash[key].nil?
        if key.class == Symbol
          raise RBatch::Config::Exception, "Value of key(:#{key} (Symbol)) is nil. By any chance, dou you mistake key class Symbol for String?"
        elsif key.class == String
          raise RBatch::Config::Exception, "Value of key(\"#{key}\" (String)) is nil"
        else
          raise RBatch::Config::Exception, "Value of key(#{key}) is nil."
        end
      else
        @hash[key]
      end
    end
    def path ; @path ; end
    def exist? ; ! @hash.nil? ; end
    def to_h
      if @hash.nil?
        raise RBatch::Config::Exception, "Config file \"#{@path}\" does not exist"
      else
        @hash
      end
    end
    def to_s
      if @hash.nil?
        raise RBatch::Config::Exception, "Config file \"#{@path}\" does not exist"
      else
        @hash.to_s
      end
    end
  end

  class RBatch::Config::Exception < Exception; end
end

