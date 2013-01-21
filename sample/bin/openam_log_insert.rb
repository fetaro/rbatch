# -*- coding: utf-8 -*-
require 'rbatch'
require 'mysql'

#
# OpenAMの認証アクセスログと認証エラーログを解析してMySQLに挿入する
#


# ログの1行を表すクラス
class Entry

  # 行をマッチさせる正規表現
  @@reg=/^
        \"(\S+\s\S+)\"  #  0 "YYYY-MM-DD HH:MM:SS"
        \t          #   タブ
        \S+         #   xxx
        \t          #   タブ
        (\S+)       # 1 "DN"
        \t          #   タブ
        \S+         #   xxx
        \t          #   タブ
        (\S+)       # 2 IP
        \t          #   タブ
        \S+         #   xxx
        \t          #   タブ
        \S+         #   xxx
        \t          #   タブ
        \S+         #   xxx
        \t          #   タブ
        (\S+)       # 3 ステータス
        \t          #   タブ
        \S+         #   xxx
        \t          #   タブ
        \S+         #   xxx
        \t          #   タブ
        \S+         #   xxx
        $/x

  @entry

  def initialize(line)
    match = line.match(@@reg)
    raise "parse error. line: <#{line}> " if match.nil?
    captures = match.captures
    captures[1] = "-" if !  captures[1] =~ /uid=|id=/
    @entry = {
      :date      => DateTime.strptime(captures[0], '%Y-%m-%d %H:%M:%S'),
      :login_id  => captures[1].split(",")[0].split("=")[1],
      :access_ip => captures[2],
      :status    => RBatch::config["auth_status"][captures[3]]
    }
  end

  # Insert用のSQLを返す
  def insert_sql(table_name,host_name,companyId)
    value = [  companyId ,
               @entry[:date].strftime("%Y/%m/%d %H:%M:%S"),
               @entry[:login_id],
               @entry[:access_ip],
               host_name,
               @entry[:status]
            ].map{|s| "'#{s}'"}.join(",")
    return "INSERT INTO #{table_name} (companyId,date,login_id,access_ip,host_name,status)  VALUES (#{value})"
  end
end

# メイン

RBatch::Log.new do |log|
  log.info("Start -----------------");
  entries = []

  # 認証アクセスログ読み込み
  File.foreach(RBatch::config["openam_access_log_path"]) do |line|
    begin
      entries << Entry.new(line)
    rescue => e
p e
    end
  end

  # 認証エラーログ読み込み
  File.foreach(RBatch::config["openam_error_log_path"]) do |line|
    begin
      entries << Entry.new(line)
    rescue => e
    end
  end

  # MySQLに接続
  con = Mysql.new(RBatch::config["mysql_server"],
                  RBatch::config["mysql_user"],
                  RBatch::config["mysql_password"],
                  RBatch::config["mysql_db_name"])
  # MySQLに挿入
  entries.each do |entry|
    sql = entry.insert_sql(RBatch::config["mysql_table_name"],
                           RBatch::config["host_name"],
                           RBatch::config["company_id"])
    log.info("exec sql: " + sql);
    con.query(sql)
  end
end

