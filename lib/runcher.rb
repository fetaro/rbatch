require 'digest/md5'
require 'fileutils'
# Wrapper of Kernel#spawn
#
# params : *cmd_params : command string
#   ex)  cmd "ls -l"
#
# return : [stdout,stderr,status]
#
def cmd(*cmd_params)
  tmp_dir="."
  if ! Dir.exist?(tmp_dir)
    raise "Temporary directory(#{tmp_dir}) does not exist"
  end
  # generate tmp file name from hash value of *cmd_params
  suffix = Digest::MD5.new.update(*cmd_params.join("")).to_s + rand.to_s
  tmp_out = File.join(tmp_dir, ".tmp_out_" + suffix)
  tmp_err = File.join(tmp_dir, ".tmp_err_" + suffix)
  [tmp_out,tmp_err].each do |f|
    if File.exist?(f)
      raise "Temporary file(#{f}) already exists"
    end
  end
  begin
    pid = spawn(*cmd_params,:out => [tmp_out,"w"],:err => [tmp_err,"w"])
    status =  Process.waitpid2(pid)[1] >> 8
    stdout = File.read(tmp_out)
    stderr = File.read(tmp_err)
  ensure
    [tmp_out,tmp_err].each do |f|
      FileUtils.rm([f]) if File.exist?(f)
    end
  end
  return {:stdout => stdout , :stderr => stderr, :status => status}
end
