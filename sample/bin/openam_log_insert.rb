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
        \"          #   "
        (\S+\s\S+)  # 0 YYYY-MM-DD HH:MM:SS
        \"          #   "
        \t          #   タブ
        .+          #   任意の文字列
        \t          #   タブ
        (.+)        # 1 "DN"
        \t          #   タブ
        .+          #   任意の文字列
        \t          #   タブ
        (.+)        # 2 IP
        \t          #   タブ
        .+          #   任意の文字列
        \t          #   タブ
        .+          #   任意の文字列
        \t          #   タブ
        .+          #   任意の文字列
        \t          #   タブ
        (.+)        # 3 ステータス
        \t          #   タブ
        .+          #   任意の文字列
        \t          #   タブ
        .+          #   任意の文字列
        \t          #   タブ
        .+          #   任意の文字列
        $/x

  @entry

  def initialize(line,status_map)
    match = line.match(@@reg)
    raise "parse error. line: <#{line}> " if match.nil?
    captures = match.captures
    if captures[1] =~ /uid=|id=/
      login_id = captures[1].split(",")[0].split("=")[1]
    else
      login_id = "-"
    end
    if status_map.has_key?(captures[3])
      status = status_map[captures[3]]
    else
      status = "-"
    end
    @entry = {
      :date      => DateTime.strptime(captures[0], '%Y-%m-%d %H:%M:%S'),
      :login_id  => login_id,
      :access_ip => captures[2],
      :status    => status
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
  status_map = RBatch::config["auth_status"]
  # 認証アクセスログ読み込み
  File.foreach(RBatch::config["openam_access_log_path"]) do |line|
    begin
      entries << Entry.new(line,status_map)
    rescue => e
      # 解析に失敗した場合
      log.warn("parse error: " + e )
    end
  end

  # 認証エラーログ読み込み
  File.foreach(RBatch::config["openam_error_log_path"]) do |line|
    begin
      entries << Entry.new(line,status_map)
    rescue => e
      # 解析に失敗した場合
      p e.backtrace
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

