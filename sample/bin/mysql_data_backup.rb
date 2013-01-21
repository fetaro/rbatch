require 'fileutils'
require 'rbatch'

RBatch::Log.new do | log |
  log.info "Start mysql data backup"
  # read config
  remote_backup_dir   = RBatch::config["remote_backup_dir"]
  local_backup_dir    = RBatch::config["local_backup_dir"]
  gpg_passphrase_file = RBatch::config["gpg_passphrase_filepath"]
  local_delete_date   = RBatch::config["local_delete_date"]
  file_dump = RBatch::config["work_dir"] + Time.now.strftime("%Y%m%d_%H%M%S") + ".mysqldump"
  file_targz = file_dump + ".tar.gz"
  file_gpg = file_targz + ".gpg"
  # main
  cmd1 = "mysqldump --single-transaction --flush-logs --master-data=2 --all-databases  > #{file_dump}"
  log.info(cmd1)
  RBatch::cmd(cmd1)

  cmd2 = "tar zcvf #{file_targz} #{file_dump}"
  log.info(cmd2)
  RBatch::cmd(cmd2)

  cmd3 = "gpg --batch --cipher-algo AES256 --passphrase-file #{gpg_passphrase_file} --passphrase-repeat 0 --output #{file_gpg} -c #{file_targz}"
  log.info(cmd3)
  RBatch::cmd(cmd3)

  log.info("cp #{file_gpg} #{local_backup_dir}")
  FileUtils.cp(file_gpg, local_backup_dir)

  log.info "cp #{file_gpg} #{remote_backup_dir}"
  FileUtils.cp(file_gpg, remote_backup_dir)

  # delete old local backup files
  Dir::foreach(local_backup_dir) do |file|
    reg = Regexp.new("([0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9])_[0-2][0-9][0-5][0-9][0-5][0-9].mysqldump.tar.gz.gpg")
    if reg =~ file && Date.strptime($1,"%Y%m%d") <= Date.today - local_delete_date
      log.info "Delete old backup file: " + File.join(local_backup_dir, file)
      File::delete(File.join(local_backup_dir, file))
    end
  end
  log.info("Success Finish")
end
