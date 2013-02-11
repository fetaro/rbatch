[[English]](https://github.com/fetaro/rbatch/blob/master/README.md "english") [[Japanese]](https://github.com/fetaro/rbatch/blob/master/README.ja.md "japanese")

RBatch:Ruby-base バッチスクリプトフレームワーク
=============

RBatchについて
--------------
これはRubyで書かれたシンプルなバッチスクリプトのフレームワークです。
バッチスクリプト（バックアップやプロセスリロード等）を書く際に便利な機能をフレームワークとして提供しています。

主な機能は以下のとおり。 

* 自動ログ出力
* 自動設定ファイル読み込み
* 外部コマンド実行 
* ファイル名・ディレクトリ構造制約
* 二重起動チェック

このフレームワークはRuby 1.9.x以降で動作します。また、Rubyプラットフォームは"linux","mswin","mingw","cygwin"で動作します。

### 自動ログ出力
Logging blockを使うことで、自動的にログファイルに出力することができます。
ログファイルはデフォルトで"../log/YYYYMMDD_HHMMSS_${PROG_NAME}.log"に出力されます。
例外が発生した場合でも、ログにスタックトレースを出力することができます。
また、エラーが発生した場合に自動でメールを送信することもできます。

サンプル

スクリプト : ./bin/sample1.rb
```
require 'rbatch'

RBatch::Log.new(){ |log|  # Logging block
  log.info "info string"
  log.error "error string"
  raise "exception"
}
```

ログファイル : ./log/20121020_005953_sample1.log
```
# Logfile created on 2012-10-20 00:59:53 +0900 by logger.rb/25413
[2012-10-20 00:59:53 +900] [INFO ] info string
[2012-10-20 00:59:53 +900] [ERROR] error string
[2012-10-20 00:59:53 +900] [FATAL] Caught exception; existing 1
[2012-10-20 00:59:53 +900] [FATAL] exception (RuntimeError)
    [backtrace] test.rb:6:in `block in <main>'
    [backtrace] /usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in `initialize'
    [backtrace] test.rb:3:in `new'
    [backtrace] test.rb:3:in `<main>'
```

### 自動設定ファイル読み込み

RBatchは簡単にデフォルトの位置の設定ファイルを読み込めます。
デフォルトの位置は"(スクリプトのパス)/../conf/${PROG_NAME}.yaml"です。

サンプル

設定ファイル : ./conf/sample2.yaml
```
key: value
array:
 - item1
 - item2
 - item3
```

スクリプト : ./bin/sample2.rb
```
require 'rbatch'
p RBatch::config
=> {"key" => "value", "array" => ["item1", "item2", "item3"]}
p RBatch::config["key"]
=> "value"

# もしキーが存在しない場合は自動的に例外が発生します
p RBatch::config["not_exist"]
=> Raise Exception
```

### 外部コマンド実行 
RBatchは外部コマンド（たとえば"ls -l"）を実行するラッパー関数を提供します。

この関数は、実行結果をオブジェクトで返し、そのオブジェクトは標準出力、標準エラー出力、およびexitステータスを含みます。

サンプル
```
require 'rbatch'
r = RBatch::cmd("ls")
p r.stdout
=> "fileA\nfileB\n"
p r.stderr
=> ""
p r.status
=> 0
```

### ファイル名・ディレクトリ構造制約

RBatchでは、「設定より規約」(convention over configuration)という原則に従い、バッチスクリプトで必要になるファイル群に、ファイル名とディレクトリ構造の制約をもたせます。

具体的には、"bin/hoge.rb"というバッチスクリプトでは、"conf/hoge.yaml"という設定ファイルを読み、
"log/YYYYMMDD_HHMMSS_hoge.rb"というログを出力するという規則です。

これにより、バッチスクリプトの可読性・保守性が向上します。

```
./
 |-bin
 |  |- hoge.rb
 |  |- bar.rb
 |-conf
 |  |- hoge.yaml
 |  |- bar.yaml
 |-log
    |- YYYYMMDD_HHMMSS_hoge.log
    |- YYYYMMDD_HHMMSS_bar.log
```

### 二重起動チェック

RBatchの共通設定ファイルに"forbid_double_run: true"の設定を書けば、RBatchを利用したスクリプトの二重起動チェックができます。

クイックスタート
--------------
### ステップ1: インストール

```
# gem install rbatch
```

### ステップ2: ディレクトリ作成

```
$ mkdir bin log conf
```

### ステップ3: バッチスクリプト作成 

bin/backup.rbは以下の通り。
```
require 'rbatch'

RBatch::Log.new(){|log|
  log.info( "start backup" )
  result = RBatch::cmd( "cp -p /var/log/message /backup")
  log.info( result )
  log.error ( "backup failed") if result.status != 0
}
```

### ステップ4: 実行

```
$ ruby bin/backup.rb
```

### ステップ5: 確認

自動的にlog/YYYYMMDD_HHMMSS_backup.logにログファイルが出ます。 

```
$ cat log/YYYYMMDD_HHMMSS_backup.log

# Logfile created on 2012-10-20 00:19:23 +0900 by logger.rb/25413
[2012-10-20 00:19:23 +0900] [INFO ] start backup
[2012-10-20 00:19:23 +0900] [INFO ] {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
[2012-10-20 00:19:23 +0900] [ERROR] backup failed
```


マニュアル
--------------

### RBatch全体設定ファイル

以下の場所にRBatch全体設定ファイルを配置すると、全てのスクリプトにてオプションが適用される。

```
(スクリプトのパス)/../conf/rbatch.yaml
```

設定ファイルのサンプルは以下の通り
```
# RBatch 全体設定
#
#   設定ファイルの形式はYAML形式です
#

# -------------------
# 全体
# -------------------

# スクリプトの二重起動を可能にするかどうか
#
#   デフォルト値はfalse。
#   trueにすると、同じスクリプトは二つ同時に起動できなくなります。
#
#forbid_double_run: true
#forbid_double_run: false

# -------------------
# 外部コマンド実行関連
# -------------------

# 例外発生機能を有効にするかどうか
#
#   デフォルト値はfalse。
#   trueの場合、コマンドの終了ステータスが0でない場合に例外を発生する。
#
#cmd_raise: true
#cmd_raise: false

# -------------------
# ログ関連
# -------------------

# ログファイル名
#
#   デフォルト値は"<date>_<time>_<prog>.log"。
#   以下の文字列は予約語
#   <data> --> YYYYMMDDの日付形式に置換されます
#   <time> --> hhmmssの時刻形式に置換されます
#   <prog> --> 拡張子を除いたファイル名に置換されます
#   <host> --> ホスト名に置換されます
#
#log_name : "<date>_<time>_<prog>.log"
#log_name : "<date>_<prog>.log"

# ログ出力ディレクトリ
#
#   デフォルト値は"(スクリプトの配置パス)/../log"。
#
#log_dir : "/tmp/log"

# ログを追記するかどうか
#
#   デフォルト値はture。
#
#log_append : true
#log_append : false

# ログレベル
#
#   デフォルト値は"info"。
#   設定できる値は"debug","info","wran","error","fatal"。
#
#log_level : "debug"
#log_level : "info"
#log_level : "warn"
#log_level : "error"
#log_level : "fatal"

# 標準出力とログの両方に文字列を出力するかどうか
#
#   デフォルト値はfalse。
#
#log_stdout : true
#log_stdout : false

# 古いログを削除するかどうか
#
#   デフォルト値はfalse。
#   trueの場合、RBatch::Log.newを呼んだタイミングで、古いログを削除する。
#   削除対象のログは、そのRBatch::Logのインスタンスが出力するログファイルと
#   同じファイル名フォーマットであり、かつログファイル名のフォーマットに<date>が
#   含まれるもの。
#   例えば、RBatch::Logで出力するログファイルが「20120105_hoge.log」だった場合、
#   削除対象のログは「YYYYMMDD_hoge.log」のログとなる。
#
#log_delete_old_log: true
#log_delete_old_log: false

# 古いログの残す日数
#
#   デフォルト値は 7
#
#log_delete_old_log_date: 14

# メール送信するかどうか
# 
#   デフォルト値は false。
#   log.error(msg)かlog.fatal(msg) を呼び出したときに,"msg"の内容をメールで送信する。
#
#log_send_mail : true

# メール送信のパラメータ
#
#log_mail_to   : "xxx@sample.com"
#log_mail_from : "xxx@sample.com"
#log_mail_server_host : "localhost"
#log_mail_server_port : 25

```
