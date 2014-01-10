module RBatch
  class Controller
    @@journal_verbose_map = { :error => 1, :warn => 2, :info => 3, :debug => 4}
    attr :program_name,:program_path
    attr :home_dir,:log_dir,:conf_dir,:lib_dir
    attr :run_conf_path, :run_conf
    attr :config, :config_path
    attr :common_config, :common_config_path
    attr :journals,:logs
    def initialize
      @journals = []
      @logs = []
      if ENV["RB_VERBOSE"]
        @journal_verbose = ENV["RB_VERBOSE"].to_i
      else
        @journal_verbose = 3
      end
      @program_name = $PROGRAM_NAME
      @program_base = File.basename($PROGRAM_NAME)
      @program_path = File.expand_path(@program_name)
      if  ENV["RB_HOME"]
        @home_dir = File.expand_path(ENV["RB_HOME"])
      else
        @home_dir =  File.expand_path(File.join(File.dirname(@program_name) , ".."))
      end
      @run_conf_path = File.join(@home_dir,".rbatchrc")
      @run_conf = RunConf.new(@run_conf_path,@home_dir)
      journal :info, "=== START RBatch === (PID=#{$$.to_s})"
      journal :debug,"RB_HOME : \"#{@home_dir}\""
      journal :info, "Load Run-Conf: \"#{@run_conf_path}\""
      journal :debug,"RBatch option : #{@run_conf.inspect}"
      @lib_dir  = @run_conf[:lib_dir].gsub("<home>",@home_dir)
      @conf_dir = @run_conf[:conf_dir].gsub("<home>",@home_dir)
      @log_dir  = @run_conf[:log_dir].gsub("<home>",@home_dir)
      # common config
      @common_config_path = File.join(@conf_dir,@run_conf[:common_conf_name])
      @common_config = RBatch::Config.new(@common_config_path)
      journal :info, "Load Config  : \"#{@common_config_path}\"" if ! @common_config.nil?
      # user config
      @config_path = File.join(@conf_dir,Pathname(File.basename(@program_name)).sub_ext(".yaml").to_s)
      @config = RBatch::Config.new(@config_path)
      journal :info, "Load Config  : \"#{@config_path}\"" if ! @config.nil?
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
            journal :info, "Load Library : \"#{File.join(@lib_dir,file)}\" "
          end
        end
      end
      journal :info,"Start Script : \"#{@program_path}\""
    end #end def
    def journal(level,str)
      if @@journal_verbose_map[level] <= @journal_verbose
        str = "[RBatch] " + str
        puts str
        @journals << str
        @logs.each do |log|
          if RBatch.run_conf[:mix_rbatch_msg_to_log]
            log.journal(str)
          end
        end
      end
    end
    def add_log(log)
      @logs << log
    end
  end
end
