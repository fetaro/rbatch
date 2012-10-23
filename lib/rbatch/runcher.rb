require 'fileutils'
require 'tempfile'

module RBatch

  class CMDResult
    @stdout_file
    @stderr_file
    @status
    def initialize(stdout_file, stderr_file,status)
      @stdout_file = stdout_file
      @stderr_file = stderr_file
      @status = status
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
  #  p RBatch::run("ls")
  #  => {:stdout => "fileA\nfileB\n", :stderr => "", :status => 0}
  # ==== Params
  # +cmd_params+ = command string.
  # ==== Return
  # {:stdout => stdout , :stderr => stderr, :status => status}
  def run(*cmd_params)
    case RUBY_PLATFORM
    when /mswin|mingw/
      tmp_dir = ENV["TEMP"]
    when /cygwin|linux/
      tmp_dir = "/tmp/"
    else
      raise "Unknown RUBY_PRATFORM : " + RUBY_PLATFORM
    end
    tmp_out = Tempfile::new("rbatch_tmpout",tmp_dir)
    tmp_err = Tempfile::new("rbatch_tmperr",tmp_dir)
    begin
      pid = spawn(*cmd_params,:out => [tmp_out,"w"],:err => [tmp_err,"w"])
      status =  Process.waitpid2(pid)[1] >> 8
      stdout = File.read(tmp_out)
      stderr = File.read(tmp_err)
    ensure
      [tmp_out,tmp_err].each do |f|
        f.close(true)
      end
    end
    return {:stdout => stdout , :stderr => stderr, :status => status}
  end

end
