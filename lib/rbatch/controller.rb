require 'rbatch/variables'
require 'rbatch/journal'
require 'rbatch/run_conf'
require 'rbatch/double_run_checker'
require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/cmd'

module RBatch
  # @private
  class Controller
    attr :vars,:config,:common_config,:journal,:user_logs
    def initialize
      @vars = RBatch::Variables.new()
      RBatch::Journal.def_vars = @vars
      RBatch::Log.def_vars = @vars
      RBatch::Cmd.def_vars = @vars
      @journal = RBatch::Journal.new()
      RBatch::Log.journal = @journal
      @user_logs = []
      @journal.put 1,"=== START RBatch === (PID=#{$$.to_s})"
      @journal.put 1, "RB_HOME : \"#{@vars[:home_dir]}\""
      @journal.put 1, "Load Run-Conf: \"#{@vars[:run_conf_path]}\""
      @journal.put 2, "RBatch Variables : #{@vars.inspect}"
      @common_config = RBatch::Config.new(@vars[:common_config_path])
      @journal.put 1, "Load Config  : \"#{@vars[:common_config_path]}\"" if @common_config.exist?
      @config = RBatch::Config.new(@vars[:config_path])
      @journal.put 1, "Load Config  : \"#{@vars[:config_path]}\"" if @config.exist?

      # double_run_check
      if ( @vars[:forbid_double_run])
        RBatch::DoubleRunChecker.check(@pvars[:rogram_base]) #raise error if check is NG
        RBatch::DoubleRunChecker.make_lock_file(@vars[:program_base])
      end
      # load_lib
      if @vars[:auto_lib_load] && Dir.exist?(@vars[:lib_dir])
        Dir::foreach(@vars[:lib_dir]) do |file|
          if /.*rb/ =~ file
            require File.join(@vars[:lib_dir],File.basename(file,".rb"))
            @journal.put 1, "Load Library : \"#{File.join(@vars[:lib_dir],file)}\" "
          end
        end
      end
      @journal.put 1, "Start Script : \"#{@vars[:program_path]}\""
    end #end def
    def config ; @config ; end
    def common_config ; @common_config ; end
    def cmd(cmd_str,opt)
      RBatch::Cmd.new(cmd_str,opt).run
    end
  end
end
