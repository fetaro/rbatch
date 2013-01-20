# -*- coding: utf-8 -*-
require 'rbatch'
require 'mysql'



#
# Apacheのアクセスログを解析してMySQLに挿入する
#

# ログの1行を表すクラス
class Entry
  # 行をマッチさせる正規表現
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

  # ログの1行を解析してEntryクラスを作る。
  # 解析できない時は例外を発生させる。
  #
  # 期待しているフォーマットは以下の通り。
  #
  #   %h %{X-Forwarded-For}i %l %u %t %T %D \"%r\" %>s %b \"%{User-Agent}i\" \"%{Referer}i\"
  #
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

  # Insert用のSQLを返す
  def insert_sql(table_name,host_name,company_id)
    value = [ "'" + company_id + "'"  ,
              "'" + @entry[:datetime].strftime("%Y/%m/%d %H:%M:%S") + "'",
              "'" + @entry[:user] + "'"  ,
              "'" + @entry[:ip_address] + "'",
              "'" + host_name + "'" ,
              "'" + @entry[:request] + "'" ,
              @entry[:sec].to_s,
              @entry[:status].to_s,
              "'" + @entry[:user_agent]  + "'" ,
              "'" + @entry[:referer]  + "'"
            ].join(",")

    return "INSERT INTO #{table_name} (companyId,date,login_id,access_ip,host_name,access_url,forward_time,httpstatus,user_agent,referer) VALUES (#{value})"
  end
end

# メイン

RBatch::Log.new do |log|
  log.info("Start -----------------");
  entries = []

  # アクセスログ読み込み
  File.foreach(RBatch::config["apache_log_path"]) do |line|
    entries << Entry.new(line.chomp)
  end

  # MySQLに接続
  con = Mysql.new(RBatch::config["mysql_server"],
                  RBatch::config["mysql_user"],
                  RBatch::config["mysql_password"],
                  RBatch::config["mysql_db_name"])
  con.autocommit(false)
  # MySQLに挿入
  begin
    log.info("start transaction")
    con.query("START TRANSACTION;")
    entries.each do |entry|
      sql = entry.insert_sql(RBatch::config["mysql_table_name"],
                             RBatch::config["host_name"],
                             RBatch::config["company_id"])
      log.info("exec sql: " + sql);
      con.query(sql)
    end
    # コミット
    con.commit
    log.info("Sucess Commit");
  rescue => e
    # ロールバック
    con.rollback
    log.error(e);
    log.info("MySQL Error Occuerred. Rollback done.");
  end
end

