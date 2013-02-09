[[English]](https://github.com/fetaro/rbatch/blob/master/README.md "english") [[Japanese]](https://github.com/fetaro/rbatch/blob/master/README.ja.md "japanese")

RBatch:Ruby-base Simple Batch Framework
=============

About RBatch
--------------
This is a Ruby-base Batch Script Framework. RBatch offer a convenient function as a framework, when you write a batch script such as "data backup script" or "proccess start script".

There are following functions. 

* Auto Logging
* Auto Config Reading
* External Command Wrapper 
* Directory Structure convention
* Double Run Check

This work on only Ruby 1.9.x or more later.

### Auto Logging
Use Auto Logging block, RBatch automatically write to logfile.
Log file default location is "(script file path)/../log/YYYYMMDD_HHMMSS_${PROG_NAME}.log" .
If exception occuerd, then RBatch write stack trace to logfile.

sample

script : ./bin/sample1.rb
```
require 'rbatch'

RBatch::Log.new(){ |log|  # Logging block
  log.info "info string"
  log.error "error string"
  raise "exception"
}
```

logfile : ./log/20121020_005953_sample1.log
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

### Auto Config Reading

RBatch easy to read config file (located on "(script file path)/../conf/${PROG_NAME}.yaml")

sample

config : ./conf/sample2.yaml
```
key: value
array:
 - item1
 - item2
 - item3
```

script : ./bin/sample2.rb
```
require 'rbatch'
p RBatch::config
=> {"key" => "value", "array" => ["item1", "item2", "item3"]}
p RBatch::config["key"]
=> "value"

# If key does not exist , raise exception
p RBatch::config["not_exist"]
=> Raise Exception
```

### External Command Wrapper 
RBatch provide a function which wrap external command (such as 'ls').

This function return a result object which contain command's STDOUT, STDERR ,and exit status.

sample
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

### Directory Structure Convention

Follow the axiom of "convention over configuration", RBatch restrict file naming rule and directory structure.

For exsample, If you make "bin/hoge.rb", you should name config file to "conf/hoge.yaml". And the name of log file is decided on "log/YYYYMMDD_HHMMSS_hoge.rb"

In this way, maintainability and readability of batch script get higher.

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

### Double Run Check

Forbit double run of the RBatch script by writing option "forbid_double_run: true" to the common configuration file.

Quick Start
--------------
### Step1: Install

```
# gem install rbatch
```

### Step2: Make directories

```
$ mkdir bin log conf
```

### Step3: Write batch script 

for bin/backup.rb
```
require 'rbatch'

RBatch::Log.new(){|log|
  log.info( "start backup" )
  result = RBatch::cmd( "cp -p /var/log/message /backup")
  log.info( result )
  log.error ( "backup failed") if result.status != 0
}
```

### Step4: Run

```
$ ruby bin/backup.rb
```

### Step5: Check

Log file is generated automatically. 

```
$ cat log/YYYYMMDD_HHMMSS_backup.log

# Logfile created on 2012-10-20 00:19:23 +0900 by logger.rb/25413
[2012-10-20 00:19:23 +0900] [INFO ] start backup
[2012-10-20 00:19:23 +0900] [INFO ] {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
[2012-10-20 00:19:23 +0900] [ERROR] backup failed
```


Manual
--------------

### RBatch Grobal Config File

If you make follow config file, option value effect to all scripts.

```
(script file path)/../conf/rbatch.yaml
```

Config Sample
```
# RBatch Common Config
#
#   This file format is YAML.
#

# -------------------
# Global setting
# -------------------

# Forbit Script Double Run
#
#   Default is false.
#   If this option is true, two same script cannot start at the same time. 
#
#forbid_double_run: true
#forbid_double_run: false

# -------------------
# Cmd setting
# -------------------

# Raise Exception
#
#   Default is false.
#   If command exit status is not 0, raise exception.
#
#cmd_raise : true
#cmd_raise : false


# -------------------
# Log setting
# -------------------

# Log File Name
#
#   Default is "<date>_<time>_<prog>.log".
#   Reservation words are follows.
#   <data> --> replace to YYYYMMDD date string
#   <time> --> replace to hhmmss time string
#   <prog> --> Program file base name (except extention)
#
#log_name : "<date>_<time>_<prog>.log"
#log_name : "<date>_<prog>.log"

# Log Output Directory
#
#   Default is "(Script path)/../log".
#
#log_dir : "/tmp/log"

# Append log or not
#
#   Default is ture.
#
#log_append : true
#log_append : false

# Log Level
#
#   Default is "info".
#   Effective values are "debug","info","wran","error",and "fatal".
#
#log_level : "debug"
#log_level : "info"
#log_level : "warn"
#log_level : "error"
#log_level : "fatal"

# Print log-string both file and STDOUT
#
#   Default is false.
#
#log_stdout : true
#log_stdout : false

# Delete old log files
#
#   Default is false.
#   If this is true, delete old log file when RBatch::Log.new is called.
#   A log file to delete is a log file which was made by the RBatch::Log instance, 
#   and log filename format include "<date>".
#
#log_delete_old_log: true
#log_delete_old_log: false

# The day of leaving log files
#
#   Default is 7.
#
#log_delete_old_log_date: 14

# Send mail or not
# 
#   Default is false.
#   When log.error(msg) or log.fatal(msg) called , send e-mail including "msg". 
#
#send_mail : true

# Send mail parameters
#
#mail_to   : "xxx@sample.com"
#mail_from : "xxx@sample.com"
#mail_server_host : "localhost"
#mail_server_port : 25

```

