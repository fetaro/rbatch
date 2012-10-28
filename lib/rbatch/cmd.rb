require 'fileutils'
require 'tempfile'

module RBatch

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

  module_function

  # External command runcher.
  # 
  # * Input cmd_params into Kernel#spawn.
  # * Write command's stdout and stderr to tmp file.
  #  * If Platform is "mswin" or "mingw" , then temp directory is ENV["TEMP"]
  #  * If Platform is "linux" or "cygwin" , then temp directory is "/tmp/"
  # * Return hash object including stdout, stderr, and exit status.
  # ==== Sample
  #  require 'rbatch'
  #  r = RBatch::cmd("ls")
  #  p r.stdout
  #  => "fileA\nfileB\n"
  # ==== Params
  # +cmd_params+ = command string. Directory input to Kernel#spawn
  # ==== Return
  # instance of RBatch::CMDResult
  def cmd(*cmd_params)
    case RUBY_PLATFORM
    when /mswin|mingw/
      tmp_dir = ENV["TEMP"]
    when /cygwin|linux/
      tmp_dir = "/tmp/"
    else
      raise "Unknown RUBY_PRATFORM : " + RUBY_PLATFORM
    end
    stdout_file = Tempfile::new("rbatch_tmpout",tmp_dir)
    stderr_file = Tempfile::new("rbatch_tmperr",tmp_dir)
    pid = spawn(*cmd_params,:out => [stdout_file,"w"],:err => [stderr_file,"w"])
    status =  Process.waitpid2(pid)[1] >> 8
    return RBatch::CMDResult.new(stdout_file,stderr_file,status)
  end
end
