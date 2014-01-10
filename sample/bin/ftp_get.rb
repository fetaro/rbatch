require "rbatch"
require "net/ftp"

server=""
user=""
password=""
target_files=["",""]

RBatch::Log.new do | log |
  ftp = Net::FTP.new(server,user,password)
  log.info("ftp login: server=#{server},user=#{user},password=#{password}")
  ftp.login
  ftp.passive = true
  ftp.chdir('pub/ruby')
  files = ftp.list('ruby*')
  target_files.each do |file|
    ftp.getbinaryfile(file)
  end
  ftp.close
end
