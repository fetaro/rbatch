require 'pathname'
require 'rbatch/run_conf'

module RBatch
  # @private
  class Variables
    attr :vars,:run_conf,:merged_opt
    def initialize(run_conf=nil)
      @merged_opt = {}
      @vars = {
        :program_name => $PROGRAM_NAME ,
        :program_path => File.expand_path($PROGRAM_NAME) ,
        :program_base => File.basename($PROGRAM_NAME),
        :date => Time.now.strftime("%Y%m%d"),
        :time => Time.now.strftime("%H%M%S"),
      }
      @vars[:program_noext] = Pathname(@vars[:program_base]).sub_ext("").to_s

      case RUBY_PLATFORM
      when /mswin|mingw/
        @vars[:host_name] =  ENV["COMPUTERNAME"] ? ENV["COMPUTERNAME"] : "unknownhost"
      when /cygwin|linux/
        @vars[:host_name] = ENV["HOSTNAME"] ? ENV["HOSTNAME"] : "unknownhost"
      else
        @vars[:host_name] = "unknownhost"
      end

      if  ENV["RB_HOME"]
        @vars[:home_dir] = File.expand_path(ENV["RB_HOME"])
      else
        @vars[:home_dir] = File.expand_path(File.join(File.dirname(@vars[:program_name]), ".."))
      end
      @vars[:run_conf_path] = File.join(@vars[:home_dir],".rbatchrc")
      @run_conf = RunConf.new(@vars[:run_conf_path]) # load run_conf
      @vars.merge!(@run_conf.opt)
      @vars[:common_config_path] = File.join(@vars[:conf_dir],@vars[:common_conf_name])
      @vars[:common_config_erb_path] = @vars[:common_config_path] + ".erb"
      @vars[:config_path] = File.join(@vars[:conf_dir],@vars[:program_noext] + ".yaml")
      @vars[:config_erb_path] = @vars[:config_path] + ".erb"
    end #end def

    def[](key)
      if @vars.has_key?(key)
        if @vars[key].class == String
          @vars[key]
            .gsub("<home>", @vars[:home_dir])
            .gsub("<date>", @vars[:date])
            .gsub("<time>", @vars[:time])
            .gsub("<prog>", @vars[:program_noext])
            .gsub("<host>", @vars[:host_name])
        else
          @vars[key]
        end
      else
        raise RBatch::VariablesException, "no such key exist :" + key.to_s
      end
    end

    def raw_value(key)
      if @vars.has_key?(key)
        @vars[key]
      else
        raise RBatch::VariablesException, "no such key exist :" + key.to_s
      end
    end

    def merge!(merged_opt)
      @merged_opt = merged_opt
      @vars.merge!(merged_opt)
      return nil
    end

    def merge(merged_opt)
      @merged_opt = merged_opt
      @vars.merge!(merged_opt)
      return self
    end

  end
  # @private
  class RBatch::VariablesException < StandardError ; end
end
