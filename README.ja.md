[[English]](README.md "english") [[Japanese]](README.ja.md "japanese")

RBatch:Ruby-base バッチスクリプトフレームワーク
=============

RBatchについて
--------------
これはRubyで書かれたバッチスクリプトのフレームワークです。

主な機能は以下のとおり。 

* 自動ログ出力
* 自動設定ファイル読み込み
* 外部コマンド実行 
* ファイル名・ディレクトリ構造制約

### 自動ログ出力
Auto Logging blockを使うことで、自動的にログファイルに出力することができます。
ログファイルはデフォルトで"../log/YYYYMMDD_HHMMSS_${PROG_NAME}.log"に出力されます。
例外が発生した場合でも、ログにスタックトレースを出力することができます。

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
I, [2012-10-20T00:59:53.895528 #3208]  INFO -- : info string
E, [2012-10-20T00:59:53.895582 #3208] ERROR -- : error string
F, [2012-10-20T00:59:53.895629 #3208] FATAL -- : Caught exception; existing 1
F, [2012-10-20T00:59:53.895667 #3208] FATAL -- : exception (RuntimeError)
test.rb:6:in `block in <main>'
/usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in `initialize'
test.rb:3:in `new'
test.rb:3:in `<main>'
```

### 自動設定ファイル読み込み

RBatchは簡単にデフォルトの位置の設定ファイルを読み込めます。
デフォルトの位置は"../config/${PROG_NAME}.yaml"です。

サンプル

設定ファイル : ./config/sample2.yaml
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
p RBatch::read_config
=> {"key" => "value", "array" => ["item1", "item2", "item3"]}
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
 |-config
 |  |- hoge.yaml
 |  |- bar.yaml
 |-log
    |- YYYYMMDD_HHMMSS_hoge.log
    |- YYYYMMDD_HHMMSS_bar.log
```


クイックスタート
--------------
### ステップ1: インストール

```
# git clone git@github.com:fetaro/rbatch.git
# cd rbatch
# rake package
# gem install pkg/rbatch-1.0.0
```

### ステップ2: ディレクトリ作成

```
$ mkdir bin log config
```

### ステップ3: バッチスクリプト作成 

bin/backup.rbは以下の通り。
```
require 'rbatch'

RBatch::Log.new(){|log|
  log.info( "start backup" )
  result = RBatch::cmd( "cp -p /var/log/message /backup")
  log.debug( result.to_h )
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
I, [2012-10-20T00:19:23.422876 #2357]  INFO -- : start backup
I, [2012-10-20T00:19:23.424773 #2357] DEBUG -- : {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
E, [2012-10-20T00:19:23.424882 #2357] ERROR -- : backup failed
```