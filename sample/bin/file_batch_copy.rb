require 'rbatch'

# File butch copy
RBatch::Log.new do |log|
  require 'fileutils'
  target_dir = RBatch::config["target_dir"]
  RBatch::config["file_list"].each do | file |
    log.info("copy " + file + " " + target_dir)
    FileUtils.cp_r(file,target_dir)
  end
end

