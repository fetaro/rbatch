# -*- coding: utf-8 -*-
require 'rbatch'
require 'mysql'

#
# WebAgentの認可ログを解析してMySQLに挿入する
#

# OpenAMエージェントの認可ログの一行
class Entry
  # 行をマッチさせる正規表現
  @@reg=/^
        (\S+\s\S+)  #  0 YYYY-MM-DD HH:MM:SS
        \.\d\d\d    #   .sss
        \s          #   半角スペース
        \s          #   半角スペース
        \s          #   半角スペース
        \s          #   半角スペース
        Info
        \s          #   半角スペース
        \S+         #   xxxxxx:xxxxxx
        \s          #   半角スペース
        LocalAuditLog:
        \s          #   半角スペース
        User
        \s          #   半角スペース
        (\S+)       # 1 user_id
        \s          #   半角スペース
        was
        \s          #   半角スペース
        (\S+)       # 2 allowed or denied
        \s          #   半角スペース
        access
        \s          #   半角スペース
        to
        \s          #   半角スペース
        (\S+)       # 3 request
        $/x

  @@status_map = {"allowed" => "ALLOW","denied" => "DISALLOW"}
  @entry

  # ログの1行を解析してEntryクラスを作る。
  # 解析できない時は例外を発生させる。
  #
  # 期待しているフォーマットは以下の通り。
  #
  #   2012-07-20 11:04:45.059    Info 24006:16ed0460 LocalAuditLog: User amadmin was allowed access to http://www.fx.develop.jp:80/.
  #
  def initialize(line,url_ignore_keywords)
    match = line.match(@@reg)
    raise "parse error. line: <#{line}> " if match.nil?
    captures = match.captures
    url_ignore_keywords.each do | keyword |
      raise "ignore keyword include in access_url: <#{line}}>" if captures[3].include?(keyword)
    end
    @entry = {
      :datetime        => DateTime.strptime( captures[0], '%Y-%m-%d %H:%M:%S'),
      :login_id        => captures[1],
      :status          => @@status_map[captures[2]],
      :access_url      => captures[3]
    }
  end

  # Insert用のSQLを返す
  def insert_sql(table_name,host_name,company_id)
    value = [ company_id ,
              @entry[:datetime].strftime("%Y/%m/%d %H:%M:%S"),
              @entry[:login_id],
              host_name,
              @entry[:access_url],
              @entry[:status]
            ].map{|s| "'#{s}'"}.join(",")

    return "INSERT INTO #{table_name} (companyId,date,login_id,host_name,access_url,status) VALUES (#{value})"
  end
end


# メイン

RBatch::Log.new do |log|
  log.info("Start -----------------");
  entries = []
  url_ignore_keywords =  RBatch::config["url_ignore_keywords"]
  # ログ読み込み
  File.foreach(RBatch::config["log_path"]) do |line|
    begin
      entries << Entry.new(line,url_ignore_keywords)
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

