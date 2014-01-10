require 'logger'
module RBatch
  class Controller
    attr :host_name
    attr :program_name,:program_path,:program_base
    attr :home_dir,:log_dir,:conf_dir,:lib_dir
    attr :run_conf, :run_conf_path
    attr :config, :config_path
    attr :common_config, :common_config_path
    attr :journal_verbose, :journals
    attr :user_logs
    def initialize
      @journals = []
      @user_logs = []
      # journal
      if ENV["RB_VERBOSE"]
        @journal_verbose = ENV["RB_VERBOSE"].to_i
      else
        @journal_verbose = 1
      end
      journal 1,"=== START RBatch === (PID=#{$$.to_s})"
      # host_name
      case RUBY_PLATFORM
      when /mswin|mingw/
        @host_name =  ENV["COMPUTERNAME"] ? ENV["COMPUTERNAME"] : "unknownhost"
      when /cygwin|linux/
        @host_name = ENV["HOSTNAME"] ? ENV["HOSTNAME"] : "unknownhost"
      else
        @host_name = "unknownhost"
      end
      # program
      @program_name = $PROGRAM_NAME
      @program_base = File.basename($PROGRAM_NAME)
      @program_path = File.expand_path(@program_name)
      # home_dir
      if  ENV["RB_HOME"]
        @home_dir = File.expand_path(ENV["RB_HOME"])
      else
        @home_dir =  File.expand_path(File.join(File.dirname(@program_name) , ".."))
      end
      journal 1, "RB_HOME : \"#{@home_dir}\""
      # run_conf
      @run_conf_path = File.join(@home_dir,".rbatchrc")
      @run_conf = RunConf.new(@run_conf_path)
      journal 1, "Load Run-Conf: \"#{@run_conf_path}\""
      journal 2, "RBatch option : #{@run_conf.inspect}"
      # dirs
      @lib_dir  = @run_conf[:lib_dir].gsub("<home>",@home_dir)
      @conf_dir = @run_conf[:conf_dir].gsub("<home>",@home_dir)
      @log_dir  = @run_conf[:log_dir].gsub("<home>",@home_dir)
      # common config
      @common_config_path = File.join(@conf_dir,@run_conf[:common_conf_name])
      @common_config = RBatch::Config.new(@common_config_path)
      journal 1, "Load Config  : \"#{@common_config_path}\"" if ! @common_config.nil?
      # config
      @config_path = File.join(@conf_dir,Pathname(File.basename(@program_name)).sub_ext(".yaml").to_s)
      @config = RBatch::Config.new(@config_path)
      journal 1, "Load Config  : \"#{@config_path}\"" if ! @config.nil?
      # double_run_check
      if ( @run_conf[:forbid_double_run] )
        RBatch::DoubleRunChecker.check(@program_base) #raise error if check is NG
        RBatch::DoubleRunChecker.make_lock_file(@program_base)
      end
      # load_lib
      if @run_conf[:auto_lib_load] && Dir.exist?(@lib_dir)
        Dir::foreach(@lib_dir) do |file|
          if /.*rb/ =~ file
            require File.join(@lib_dir,File.basename(file,".rb"))
            journal 1, "Load Library : \"#{File.join(@lib_dir,file)}\" "
          end
        end
      end
      journal 1, "Start Script : \"#{@program_path}\""
    end #end def
    #
    def journal(level,str)
      if level <= @journal_verbose
        str = "[RBatch] " + str
        puts str
        @journals << str
        @user_logs.each do |log|
          if RBatch.run_conf[:mix_rbatch_journal_to_logs]
            log.journal(str)
          end
        end
      end
    end
    #
    def add_log(log)
      @user_logs << log
    end
  end
end
