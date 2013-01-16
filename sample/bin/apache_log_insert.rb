require 'rbatch'
require 'mysql'


# parse apache logfile and insert into mysql
#
#   expecting log format:
#   %h %{X-Forwarded-For}i %l %u %t %T %D \"%r\" %>s %b \"%{User-Agent}i\" \"%{Referer}i\"
#

class Entry
  @@reg=/^
        (\S+)       # 0 ip_address
        \s+
        (\S+)       # 1 X-Forwarded-For
        \s+
        (\S+)       # 2 identity_check
        \s+
        (\S+)       # 3 user
        \s+
        \[ (.*?) \] # 4 date
        \s+
        (\S+)       # 5 sec
        \s+
        (\S+)       # 6 msec
        \s+
        " (.*?) "   # 7 request
        \s+
        (\S+)       # 8 status
        \s+
        (\S+)       # 9 size
        \s+
        " (.*?) "   # 10 user_agent
        \s+
        " (.*?) "   # 11 referer
        $/x

  @entry

  def initialize(line)
    match = line.match(@@reg)
    raise "parse error. line: <#{line}> " if match.nil?
    captures = match.captures
    @entry = {
      :ip_address      => captures[1].split(",")[0],
      :user            => captures[3],
      :datetime        => DateTime.strptime( captures[4], '%d/%b/%Y:%T %z'),
      :sec             => captures[5].to_i,
      :request         => captures[7],
      :status          => captures[8].to_i,
      :user_agent      => captures[10],
      :referer         => captures[11]
    }
  end

  def insert_sql(table_name,hostname)
p @entry[:datetime].strftime("%Y/%m/%d %H:%M:%S") 
    "INSERT INTO #{table_name} (date,login_id,access_ip,host_name,access_url,forward_time,httpstatus,user_agent,referer) VALUES ("\
      + "'" + @entry[:datetime].strftime("%Y/%m/%d %H:%M:%S") + "'"  + ","\
      + "'" + @entry[:user] + "'"  + ","\
      + "'" + @entry[:ip_address] + "'"  + ","\
      + "'" + hostname + "'"  + ","\
      + "'" + @entry[:request] + "'"  + ","\
      + @entry[:sec].to_s + ","\
      + @entry[:status].to_s  + ","   \
      + "'" + @entry[:user_agent]  + "'" + ","\
      + "'" + @entry[:referer] + "'" \
      + ")"
  end
end

entries = []
File.foreach(RBatch::config["apache_log_path"]) do |line|
  entries << Entry.new(line.chomp)
end


apache_log_path = RBatch::config["apache_log_path"]
client= Mysql.connect(RBatch::config["mysql_server"],
                      RBatch::config["mysql_user"],
                      RBatch::config["mysql_password"],
                      RBatch::config["mysql_db_name"])
entries.each do |entry|
  sql = entry.insert_sql(RBatch::config["mysql_table_name"],"hoge")
  p sql
  client.query(sql)
end

