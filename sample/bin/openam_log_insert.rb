# -*- coding: utf-8 -*-
require 'rbatch'
require 'mysql'


# parse OpenAM AuthLogfile and insert into MySQL
#
#   expecting log format sample:
# 
#   "2012-07-10 20:59:55"   "Login Success|module_instance|DataStore"       id=amadmin,ou=user,dc=opensso,dc=java,dc=net       e63d790b51cf40f501      192.175.204.59  INFO    dc=opensso,dc=java,dc=net  "cn=dsameuser,ou=DSAME Users,dc=opensso,dc=java,dc=net" AUTHENTICATION-105      DataStore       "Not Available"    192.175.204.59
#
# 0  "2012-07-10 20:59:55"
# 1  "Login Success|module_instance|DataStore"
# 2  id=amadmin,ou=user,dc=opensso,dc=java,dc=net
# 3  e63d790b51cf40f501
# 4  192.175.204.59
# 5  INFO
# 6  dc=opensso,dc=java,dc=net
# 7  "cn=dsameuser,ou=DSAME Users,dc=opensso,dc=java,dc=net"
# 8  AUTHENTICATION-105
# 9  DataStore
# 10 "Not Available"
# 11 192.175.204.59
#
class Entry
  @entry = nil

  # ログの1行を解析してEntryクラスを作る。
  # 解析できない時は例外を発生させる。
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
client= Mysql.connect(RBatch::config["mysql_server"],
                      RBatch::config["mysql_user"],
                      RBatch::config["mysql_password"],
                      RBatch::config["mysql_db_name"])

# MySQLに挿入
table_name=RBatch::config["mysql_table_name"]
entries.each do |entry|
  sql = entry.insert_sql(table_name,"hostname","company_id")
  p sql
  # client.query(sql)
end

