# -*- coding: utf-8 -*-
require 'rbatch'
require 'mysql'

#
# OpenAMの認証アクセスログと認証エラーログを解析してMySQLに挿入する
#   2013/1 NRI 渡部
#


# ログの1行を表すクラス
#
class Entry
  @entry = nil

  # ログの1行を解析してEntryクラスを作る。
  # 解析できない時は例外を発生させる。
  #
  # 期待しているフォーマットは以下の通り。
  #
  # "YYYY-MM-DD HH-MM-SS" \t "xxx" \t id=xxx,ou=xx,dc=xx \t xxxx \t d.d.d.d 
  #    \t xxx \t xxx \t "xxx" \t AUTHENTICATION-XXX \t xxx \t "xxx" \t d.d.d.d
  #
  def initialize(line)
    if ! ( line =~ /^\#.*/ )
      array = line.chop.split("\t")
      if array.size == 12
        # date
        date = DateTime.strptime(array[0].delete("\""), '%Y-%m-%d %H:%M:%S')
        # login_id
        login_id = "-"
        array[2].split(",").each do | str |
          # OpenLDAP 認証モジュールの場合の、ユーザIDは、
          # "uid="で始まる為、それも取り込む
          # また、パスワード未入力や、存在しないユーザIDの場合も、
          # "uid="で出力されるように認証モジュール側を修正したので、
          # 以下のコードで取り込まれる。
          if str =~ /^uid=|id=/
            login_id = str.split("=")[1]
          end
        end
        # access_ip
        access_ip = array[4]
        # status
        begin
          status = RBatch::config["auth_status"][array[8]]
        rescue => e
          # 設定ファイルに定義していない認証ステータスの場合は、
          # RBatchが例外を出すので、ここでキャッチする
          status = nil
        end
        if ! date.nil? && ! access_ip.nil? && ! status.nil?
          @entry = {
            :date      => date,
            :login_id  => login_id,
            :access_ip => access_ip,
            :status    => status}
        end
      end
    end
    raise "Cannot parse line: #{line}" if @entry.nil?
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

##########
# メイン
RBatch::Log.new do |log|
  log.info("Start -----------------");
  entries = []

  # 認証アクセスログ読み込み
  File.foreach(RBatch::config["openam_access_log_path"]) do |line|
    begin
      entries << Entry.new(line)
    rescue => e
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
    con.rollback
    log.error(e);
    log.info("MySQL Error Occuerred. Rollback done.");
  end
end

