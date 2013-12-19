require 'fileutils'
require 'tempfile'
require 'tmpdir'

module RBatch

  # External command runcher.
  #
  #This module is a wrapper of Kernel#spawn.
  #
  # * Arguments(cmd_params) are inputed to Kernel#spawn directly and run command.
  # * Command's stdout and stderr is written to tmp file.
  #  * If Platform is "mswin" or "mingw" , then temp directory is ENV["TEMP"]
  #  * If Platform is "linux" or "cygwin" , then temp directory is "/tmp/"
  # * Return an object of RBatch::CmdResult which includes stdout, stderr, and exit status.
  #
  # ==== Sample 1
  #  require 'rbatch'
  #  cmd = RBatch::Cmd("ls")
  #  r = cmd.run
  #  p r.stdout
  #  => "fileA\nfileB\n"
  #
  # ==== Sample 2 ( Use option)
  #  cmd = RBatch::Cmd("ls", {:verbose => true})
  #  r = cmd.run
  #
  # ==== Sample 3 ( Use alias)
  #  require 'rbatch'
  #  r = RBatch::cmd("ls")
  #  p r.stdout
  #  => "fileA\nfileB\n"
  #
  class Cmd
    @@def_opt = {
      :raise     => false,
      :timeout   => 0
    }
    @cmd_str
    @opt

    # Cmd instance
    #
    # ==== Params
    # +cmd_str+ = Command string. Such ad "ls -l"
    # +opt+ = Option hash object. Hash keys is follows.
    # - +:raise+ (Boolean) = If command exit status is not 0, raise exception. Default is false.
    # - +:timeout+ (Integer) = If command timeout , raise exception. Default is 0 sec ( 0 means disable) .
    def initialize(cmd_str,opt = nil)
      raise(CmdException,"Command string is nil") if cmd_str.nil?
      @cmd_str = cmd_str
      # parse option
      @opt = @@def_opt.clone
      @@def_opt.each_key do |key|
        if opt != nil  && opt[key] != nil
          # use argument
          @opt[key] = opt[key]
        elsif RBatch.rbatch_config != nil \
          && RBatch.rbatch_config["cmd_" + key.to_s] != nil
          # use config
          @opt[key] = RBatch.rbatch_config["cmd_" + key.to_s]
        else
          # use default
        end
      end
    end

    # Run command
    #
    # ==== Return
    # instance of RBatch::CmdResult
    def run()
      stdout_file = Tempfile::new("rbatch_tmpout",Dir.tmpdir)
      stderr_file = Tempfile::new("rbatch_tmperr",Dir.tmpdir)
      pid = spawn(@cmd_str,:out => [stdout_file,"w"],:err => [stderr_file,"w"])
      if @opt[:timeout] != 0
        timeout(@opt[:timeout]) do
          begin
            status =  Process.waitpid2(pid)[1] >> 8
          rescue Timeout::Error => e
            raise(CmdException,"Command timeout (over " + @opt[:timeout] + " sec)" )
          end
        end
      else
        status =  Process.waitpid2(pid)[1] >> 8
      end
      result = RBatch::CmdResult.new(stdout_file,stderr_file,status,@cmd_str)
      if @opt[:raise] && status != 0
        raise(CmdException,"Command exit status is not 0. result: " + result.to_s)
      end
      return result
    end
  end

  class CmdResult
    @stdout_file
    @stderr_file
    @status
    @cmd_str
    def initialize(stdout_file, stderr_file, status, cmd_str)
      @stdout_file = stdout_file
      @stderr_file = stderr_file
      @status = status
      @cmd_str = cmd_str
    end
    def stdout_file ; @stdout_file ; end
    def stderr_file ; @stderr_file ; end
    def status      ; @status      ; end
    def cmd_str     ; @cmd_str     ; end
    def stdout
      File.read(@stdout_file)
    end
    def stderr
      File.read(@stderr_file)
    end
    def to_h
      {:cmd_str => @cmd_str,:stdout => stdout, :stderr => stderr, :status => status}
    end
    def to_s
      to_h.to_s
    end
  end

  class CmdException < Exception ; end

  module_function

  # shortcut of RBatch::Cmd
  def cmd(cmd_str,opt = nil)
    Cmd.new(cmd_str,opt).run
  end

end
