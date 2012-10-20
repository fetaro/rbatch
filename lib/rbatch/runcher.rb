require 'fileutils'
require 'tempfile'

module RBatch

  module_function

  # External command runcher.
  # 
  # * Input cmd_params into Kernel#spawn.
  # * Write command's stdout and stderr to tmp file(located at "./").
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
    tmp_dir="."
    tmp_out = Tempfile::new("tmpout",tmp_dir)
    tmp_err = Tempfile::new("tmperr",tmp_dir)
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
