require 'tmpdir'
module RBatch
  class RunConf
    attr :opt,:yaml
    @@def_opt = {
      :tmp_dir       => nil,
      :forbid_double_run => false,
      :log_name      => "<date>_<time>_<prog>.log",
      :log_conf      => "conf",
      :log_dir       => "log",
      :log_append    => true,
      :log_level     => "info",
      :log_stdout    => false,
      :log_quiet     => false,
      :log_delete_old_log => false,
      :log_delete_old_log_date => 7,
      :log_send_mail => false,
      :log_hostname => "unknownhost",
      :log_mail_to   => nil,
      :log_mail_from => "rbatch.localhost",
      :log_mail_server_host => "localhost",
      :log_mail_server_port => 25
    }

    def initialize(path)
      @opt = @@def_opt.clone
      @opt[:tmp_dir] = Dir.tmpdir
      case RUBY_PLATFORM
      when /mswin|mingw/
        @opt[:log_hostname] =  ENV["COMPUTERNAME"] ? ENV["COMPUTERNAME"] : "unknownhost"
      when /cygwin|linux/
        @opt[:log_hostname] = ENV["HOSTNAME"] ? ENV["HOSTNAME"] : "unknownhost"
      else
        @opt[:log_hostname] = "unknownhost"
      end
      begin
        @yaml = YAML::load_file(path)
        if @yaml
          @yaml.each_key do |key|
            if @@def_opt.has_key?(key.to_sym)
              @opt[key.to_sym]=@yaml[key]
            else
              raise RBatch::RunConf::Exception, "\"#{key}\" is not available option"
            end
          end
        end
      rescue
        # when run_conf does not exist, do nothing.
      end
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
  class RBatch::RunConf::Exception < Exception; end
end
