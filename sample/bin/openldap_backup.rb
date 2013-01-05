require 'rbatch'

RBatch::Log.new do |log|
  log.info("start openldap backup")
  cmd_str = "slapcat -l " + RBatch::config["backup_dir"]
  RBatch::cmd(cmd_str)
end
