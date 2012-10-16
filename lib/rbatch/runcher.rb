require 'fileutils'
require 'tempfile'
# Wrapper of Kernel#spawn
#
#   ex)  result = cmd "ls -l"
#        p result[:stdout]
#
# params : *cmd_params : command string
#
# return : {:stdout => stdout , :stderr => stderr, :status => status}
#
def cmd(*cmd_params)
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
