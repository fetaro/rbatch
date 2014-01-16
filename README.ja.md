[[English]](https://github.com/fetaro/rbatch/blob/master/README.md "english") [[Japanese]](https://github.com/fetaro/rbatch/blob/master/README.ja.md "japanese")

RBatch:Ruby-base バッチ スクリプト フレームワーク
=============

RBatchについて (version 2)
--------------

RBatchはRubyで書かれたシンプルなバッチスクリプトのフレームワークです。
バッチスクリプト（バックアップやプロセスリロード等）を書く際に便利な機能をフレームワークとして提供しています。

主な機能は以下のとおり。

* 自動ログ出力
* 自動ライブラリ読み込み
* 自動メール送信
* 自動設定ファイル読み込み
* 外部コマンド実行
* 二重起動チェック

注意：このフレームワークはRuby 1.9で動作します。

このソフトウェアは、MITライセンスのもとで公開しています。LICENSE.txtを見てください。

クイックスタート
--------------

    $ sudo gem install rbatch
    $ rbatch-init    # => ディレクトリとサンプルスクリプトが作られます
    $ ruby bin/hello_world.rb
    $ cat log/YYYYMMDD_HHMMSS_hello_world.log

マニュアル
--------------

### RBatchホームディレクトリ

環境変数`${RB_HOME}`を定義する事で、その場所をRBatchのホームディレクトリに固定することができます。

環境変数`${RB_HOME}`を定義していない場合は、「実行するスクリプトが配置されているディレクトリの親ディレクトリ」が${RB_HOME}になります。言い換えると`${RB_HOME}`のデフォルト値は`(スクリプトのパス)/../`です。

### ディレクトリ構成と命名規則

RBatchでは、実行スクリプト、設定ファイルおよびログファイルについて、
配置場所および命名規則が規約で決まっています。

具体的には、`${RB_HOME}/bin/hoge.rb`というスクリプトでは、`${RB_HOME}/lib/*.rb`にあるライブラリをロードし、`${RB_HOME}/conf/hoge.yaml`という設定ファイルを読み、`${RB_HOME}/log/YYYYMMDD_HHMMSS_hoge.rb`というログを出力するという規則です。

例を示すと以下の通りです。

    ${RB_HOME}         ←RBatchホームディレクトリ
     |
     |-.rbatchrc       ←Run-Conf
     |
     |-bin             ←実行スクリプト配置場所
     |  |- A.rb
     |  |- B.rb
     |
     |-conf            ←設定ファイル配置場所
     |  |- A.yaml
     |  |- B.yaml
     |  |- common.yaml  ←共通設定ファイル
     |
     |-log             ←ログ出力場所
     |  |- YYYYMMDD_HHMMSS_A.log
     |  |- YYYYMMDD_HHMMSS_B.log
     |
     |-lib             ←ライブラリ配置場所
         |-  lib_X.rb
         |-  lib_Y.rb

### 自動ログ出力

ログブロックを使うことで、自動的にログファイルに出力することができます。
ログファイルはデフォルトで`${RB_HOME}/log/YYYYMMDD_HHMMSS_(スクリプトのbasename).log`に出力されます。
ログブロック内で発生した例外をキャッチし、ログにスタックトレースを出力することができます。

サンプル

スクリプト`${RB_HOME}/bin/sample1.rb` を作ります

    require 'rbatch'

    RBatch::Log.new(){ |log|  # ログブロック
      log.info "info string"
      log.error "error string"
      raise "exception"
    }


実行するとログファイル`${RB_HOME}/log/20121020_005953_sample1.log`が以下のように出力されます

    # Logfile created on 2012-10-20 00:59:53 +0900 by logger.rb/25413
    [2012-10-20 00:59:53 +900] [INFO ] info string
    [2012-10-20 00:59:53 +900] [ERROR] error string
    [2012-10-20 00:59:53 +900] [FATAL] Caught exception; existing 1
    [2012-10-20 00:59:53 +900] [FATAL] exception (RuntimeError)
        [backtrace] test.rb:6:in `block in <main>'
        [backtrace] /usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in `initialize'
        [backtrace] test.rb:3:in `new'
        [backtrace] test.rb:3:in `<main>'


### 自動ライブラリ読み込み

`${RB_HOME}/lib/*.rb`にライブラリファイルを配置すると、スクリプトが起動する前に自動的に読み込まれます。

### 自動メール送信

`log_send_mail`オプションを使う事により、スクリプトでエラーが発生した場合に、自動でメールを送信することができます。

### 自動設定ファイル読み込み

RBatchは簡単にデフォルトの位置の設定ファイルを読み込めます。
デフォルトの位置は`${RB_HOME}/conf/(プログラムbasename).yaml`です。

サンプル

設定ファイル `${RB_HOME}/conf/sample2.yaml` を作ります

    key: value
    array:
     - item1
     - item2
     - item3


スクリプト`${RB_HOME}/bin/sample2.rb`で、以下のように設定値を呼び出すことができます。

    require 'rbatch'

    # 設定ファイルのロードなど無しにいきなり設定値を利用できます
    p RBatch.config["key"]    # => "value"
    p RBatch.config["array"]  # => ["item1", "item2", "item3"]

    # もしキーが存在しない場合は自動的に例外が発生します
    p RBatch.config["not_exist"] # => RBatch::ConfigExceptionが発生


#### 共通設定ファイル

すべてのスクリプトから共通で読み込む設定ファイルを作りたい場合は、`${RB_HOME}/conf/common.yaml`というファイルを作ることで可能です。

### 外部コマンド実行

RBatchは外部コマンド（たとえば"ls -l"）を実行するラッパー関数を提供します。

この関数は、実行結果をオブジェクトで返し、そのオブジェクトは標準出力、標準エラー出力、およびexitステータスを含みます。

サンプル

    require 'rbatch'
    r = RBatch.cmd("ls")
    p r.stdout # => "fileA\nfileB\n"
    p r.stderr # => ""
    p r.status # => 0


外部コマンドにタイムアウトを設定したい場合は`cmd_timeout`をオプションを利用できます。

`cmd_raise`オプションを利用することにより、コマンドの戻り値が0以外の場合、例外を発生させることができます。これによりエラーハンドリングのロジックを省略できます。

### 二重起動チェック

`forbid_double_run`のオプションを利用すれば、RBatchを利用したプログラムの二重起動チェックができます。

カスタマイズ
--------------

RBatchではオプションの指定の仕方は以下の二つがあります。

* (1) Run-Conf(`${RB_HOME}/.rbatchrc`)に書く
* (2) スクリプト内でオプションオブジェクトをコンストラクタの引数に渡す

同じオプションを(1)と(2)の両方で指定すると、(2)が優先されます。

### Run-Conf(.rbatchrc)によるカスタマイズ

Run-Conf(`${RB_HOME}/.rbatchrc`)のサンプルは以下の通り

```
# RBatch Run-Conf (.rbatchrc)
#
#   設定ファイルの形式はYAML形式です
#

# -------------------
# 全体
# -------------------

# 設定ファイルディレクトリ
#
#   デフォルトは "<home>/conf"
#   <home> は ${RB_HOME} に置き換わります
#
#conf_dir : <home>/config
#conf_dir : /etc/rbatch/

# スクリプト間共通設定ファイル名
#
#   デフォルトは"common.yaml"
#
#common_conf_name: share.yaml

# ライブラリディレクトリ
#
#   デフォルトは"<home>/lib"
#   <home> は${RB_HOME}に置き換わります
#
#lib_dir : /usr/local/lib/rbatch/

# 自動ライブラリ読み込み
#
#   デフォルトはtrue
#   trueの場合、スクリプトが始まる前に"(ライブラリディレクトリ)/*.rb"をrequireします
#
#auto_lib_load : true
#auto_lib_load : false

# スクリプトの二重起動を可能にするかどうか
#
#   デフォルト値はfalse。
#   trueにすると、同じ名前のスクリプトは二つ同時に起動できなくなります。
#
#forbid_double_run : true
#forbid_double_run : false

# RBatchの実行ログ(Journal)のLevel
#
#   デフォルトは1
#   大きい数を指定すると多くの実行ログが出力される。
#   0を指定すると何も表示されない。
#   RBatchメッセージの例
#       [RBatch] Load Config  : "../conf/hoge.yaml"
#
#rbatch_journal_level : 2
#rbatch_journal_level : 0

# RBatchの実行ログをログに混ぜ込む
#
#   デフォルトは true。
#   trueを指定すると、RBatchメッセージをその時開かれているログに混ぜこむ。
#
#mix_rbatch_journal_to_logs : true
#mix_rbatch_journal_to_logs : false

# -------------------
# ログ関連
# -------------------

# ログディレクトリ
#
#   デフォルトは "<home>/log"
#   <home> は ${RB_HOME} に置き換わります
#
#log_dir : <home>/rb_log
#log_dir : /var/log/rbatch/

# ログファイル名
#
#   デフォルト値は"<date>_<time>_<prog>.log"。
#   <data> はYYYYMMDDの日付形式に置換されます
#   <time> はhhmmssの時刻形式に置換されます
#   <prog> は拡張子を除いたファイル名に置換されます
#   <host> はホスト名に置換されます
#
#log_name : "<date>_<time>_<prog>.log"
#log_name : "<date>_<prog>.log"

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
#log_level : "warn"

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
#
#log_delete_old_log : true
#log_delete_old_log : false

# 古いログの残す日数
#
#   デフォルト値は 7
#
#log_delete_old_log_date : 14

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

# -------------------
# 外部コマンド実行関連
# -------------------

# 例外発生機能を有効にするかどうか
#
#   デフォルト値はfalse。
#   trueの場合、コマンドの終了ステータスが0でない場合に例外を発生する。
#
#cmd_raise : true
#cmd_raise : false

# 外部コマンドのタイムアウト
#
#   デフォルト値は0[sec]。
#
#cmd_timeout : 5


```

### コンストラクタの引数によるオプション指定

スクリプト内で一時的にオプションを指定したい場合は、RBatch::LogクラスもしくはRBatch::Cmdクラスのコンストラクタの引数にオプションのハッシュを指定します。

#### RBatch::Logクラスのオプション

    opt = {
          :name      => "<date>_<time>_<prog>.log",
          :dir       => "/var/log/",
          :append    => true,
          :level     => "info",
          :stdout    => false,
          :delete_old_log => false,
          :delete_old_log_date => 7,
          :send_mail => false,
          :mail_to   => nil,
          :mail_from => "rbatch.localhost",
          :mail_server_host => "localhost",
          :mail_server_port => 25
    }

    RBatch::Log.new(opt)

#### RBatch::Cmdクラスのオプション

    opt = {
          :raise     => false,
          :timeout   => 0
          }

    RBatch::Log.new(cmd_str, opt)

version 1 から 2 へのマイグレーション
--------------

`${RB_HOME}/conf/rbatch.yaml` を `${RB_HOME}/.rbatchrc` に移動してください。
