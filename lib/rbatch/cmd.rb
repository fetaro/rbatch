require 'fileutils'
require 'tempfile'

module RBatch

  # External command runcher.
  # 
  # * Input cmd_params into Kernel#spawn.
  # * Write command's stdout and stderr to tmp file.
  #  * If Platform is "mswin" or "mingw" , then temp directory is ENV["TEMP"]
  #  * If Platform is "linux" or "cygwin" , then temp directory is "/tmp/"
  # * Return hash object including stdout, stderr, and exit status.
  #
  # ==== Sample 1
  #  require 'rbatch'
  #  cmd = RBatch::CMD("ls")
  #  r = cmd.run
  #  p r.stdout
  #  => "fileA\nfileB\n"
  #
  # ==== Sample 2 ( Use option)
  #  cmd = RBatch::CMD("ls", {:verbose => true})
  #  r = cmd.run
  #
  # ==== Sample 3 ( Use alias)
  #  require 'rbatch'
  #  r = RBatch::cmd("ls")
  #  p r.stdout
  #  => "fileA\nfileB\n"
  #
  class CMD
    @@def_opt = {
      :raise     => false
    }
    @cmd_str
    @opt

    # CMD instance
    #
    # ==== Params
    # +cmd_str+ = Command string. Such ad "ls -l"
    # +opt+ = Option hash object. Hash keys is follows.
    # - +:raise+ (Boolean) = If command exit status is not 0, raise exception. Default is false.
    def initialize(cmd_str,opt = nil)
      raise(CMDException,"Command string is nil") if cmd_str.nil?
      @cmd_str = cmd_str
      # parse option
      @opt = @@def_opt.clone
      @@def_opt.each_key do |key|
        if opt != nil  && opt[key] != nil
          # use argument
          @opt[key] = opt[key]
        elsif RBatch.common_config != nil \
          && RBatch.common_config["cmd_" + key.to_s] != nil
          # use config
          @opt[key] = RBatch.common_config["cmd_" + key.to_s]
        else
          # use default
        end
      end
    end

    # Run command
    #
    # ==== Return
    # instance of RBatch::CMDResult
    def run()
      stdout_file = Tempfile::new("rbatch_tmpout",RBatch::tmp_dir)
      stderr_file = Tempfile::new("rbatch_tmperr",RBatch::tmp_dir)
      pid = spawn(@cmd_str,:out => [stdout_file,"w"],:err => [stderr_file,"w"])
      status =  Process.waitpid2(pid)[1] >> 8
      result = RBatch::CMDResult.new(stdout_file,stderr_file,status)
      if @opt[:raise] && status != 0
        raise(CMDException,"Command exit status is not 0. result: " + result.to_s)
      end
      return result
    end
  end

  class CMDResult
    @stdout_file
    @stderr_file
    @status
    def initialize(stdout_file, stderr_file, status)
      @stdout_file = stdout_file
      @stderr_file = stderr_file
      @status = status
    end
    def stdout_file ; @stdout_file ; end
    def stderr_file ; @stderr_file ; end
    def status      ; @status      ; end
    def stdout
      File.read(@stdout_file)
    end
    def stderr
      File.read(@stderr_file)
    end
    def to_h
      {:stdout => stdout, :stderr => stderr, :status => status}
    end
    def to_s
      to_h.to_s
    end
  end

  class CMDException < Exception ; end

  module_function

  # shortcut of RBatch::CMD
  def cmd(cmd_str,opt = nil)
    CMD.new(cmd_str,opt).run
  end

end
