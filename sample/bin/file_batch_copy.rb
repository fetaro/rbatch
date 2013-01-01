require 'rbatch'
require 'fileutils'
RBatch::Log.new do |log|
  RBatch::config["file_list"].each do | file |
    log.info("cp -r " + file + " " + RBatch::config["backup_dir"])
    FileUtils.cp_r(file,RBatch::config["backup_dir"])
  end
end

