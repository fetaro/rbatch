require 'tmpdir'
require 'yaml'
module RBatch
  class RunConf
    @opt
    @yaml
    attr_reader :run_conf_path
    @@def_opt = {
      :conf_dir      => "<home>/conf",
      :common_conf_name => "common.yaml",
      :lib_dir       => "<home>/lib",
      :auto_lib_load => true,
      :forbid_double_run => false,
      :cmd_raise     => false,
      :cmd_timeout   => 0,
      :log_dir       => "<home>/log",
      :log_name      => "<date>_<time>_<prog>.log",
      :log_append    => true,
      :log_level     => "info",
      :log_stdout    => false,
      :log_delete_old_log => false,
      :log_delete_old_log_date => 7,
      :log_send_mail => false,
      :log_mail_to   => nil,
      :log_mail_from => "rbatch.localhost",
      :log_mail_server_host => "localhost",
      :log_mail_server_port => 25,
      :rbatch_journal_level => 1,
      :mix_rbatch_journal_to_logs => true
    }
    def initialize(run_conf_path)
      @run_conf_path = run_conf_path
      @opt = @@def_opt.clone
      load
    end

    def reset()
      @opt = @@def_opt.clone
    end

    def reload()
      reset
      load
    end

    def load()
      begin
        @yaml = YAML::load_file(@run_conf_path)
      rescue
        # when run_conf does not exist, do nothing.
        @yaml = false
      end
      if @yaml
        @yaml.each_key do |key|
          if @@def_opt.has_key?(key.to_sym)
            @opt[key.to_sym]=@yaml[key]
          else
            raise RBatch::RunConf::Exception, "\"#{key}\" is not available option"
          end
        end
      end
    end

    def merge!(opt)
      opt.each_key do |key|
        if @opt.has_key?(key)
          @opt[key] = opt[key]
        else
          raise RBatch::RunConf::Exception, "\"#{key}\" is not available option"
        end
      end
    end

    def merge(opt)
      tmp = @opt.clone
      opt.each_key do |key|
        if tmp.has_key?(key)
          tmp[key] = opt[key]
        else
          raise RBatch::RunConf::Exception, "\"#{key}\" is not available option"
        end
      end
      return tmp
    end

    def[](key)
      if @opt[key].nil?
        raise RBatch::RunConf::Exception, "Value of key=\"#{key}\" is nil"
      end
      @opt[key]
    end

    def[]=(key,value)
      if ! @opt.has_key?(key)
        raise RBatch::RunConf::Exception, "Key=\"#{key}\" does not exist"
      end
      @opt[key]=value
    end
  end

  class RunConf::Exception < Exception ; end

end
