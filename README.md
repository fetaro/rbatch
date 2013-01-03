[[English]](https://github.com/fetaro/rbatch/blob/master/README.md "english") [[Japanese]](https://github.com/fetaro/rbatch/blob/master/README.ja.md "japanese")

RBatch:Ruby-base Batch Script Framework
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
Log file default location is "../log/YYYYMMDD_HHMMSS_${PROG_NAME}.log" .
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
I, [2012-10-20T00:59:53.895528 #3208]  INFO -- : info string
E, [2012-10-20T00:59:53.895582 #3208] ERROR -- : error string
F, [2012-10-20T00:59:53.895629 #3208] FATAL -- : Caught exception; existing 1
F, [2012-10-20T00:59:53.895667 #3208] FATAL -- : exception (RuntimeError)
test.rb:6:in `block in <main>'
/usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in `initialize'
test.rb:3:in `new'
test.rb:3:in `<main>'
```

### Auto Config Reading

RBatch easy to read config file (located on "../config/${PROG_NAME}.yaml")

sample

config : ./config/sample2.yaml
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
 |-config
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
# git clone https://github.com/fetaro/rbatch.git
# cd rbatch
# rake package
# gem install pkg/rbatch-1.0.0
```

### Step2: Make directories

```
$ mkdir bin log config
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
I, [2012-10-20T00:19:23.422876 #2357]  INFO -- : start backup
I, [2012-10-20T00:19:23.424773 #2357]  INFO -- : {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
E, [2012-10-20T00:19:23.424882 #2357] ERROR -- : backup failed
```


Manual
--------------

### Common Config File

If you make follow config file, option value effect to all scripts.

```
(script file path)/../config/rbatch.yaml
```

Config Sample
```
# RBatch Common Config
#
# This file format is YAML
#

# -------------------
# Global setting
# -------------------

# Forbit Double Run
#
#   Default : false
#
#forbid_double_run: true

# -------------------
# Cmd setting
# -------------------

# Raise Exception
#
#   Default : false
#
# If command exit status is not 0, raise exception.
#
#cmd_raise : true


# -------------------
# Log setting
# -------------------

# Log File Name
#
#   Default : "<date>_<time>_<prog>.log"
#
#   Reservation words
#   <data> --> replace to YYYYMMDD date string
#   <time> --> replace to hhmmss time string
#   <prog> --> Program file base name (except extention)
#
#log_name : "<date>_<time>_<prog>.log"
#log_name : "<date>_<prog>.log"

# Log Output Directory
#
#   Default : "(Script path)/../log"
#
#log_dir : "/tmp/log"

# Append log or not
#
#   Default : ture
#
#log_append : false

# Log Level
#
#   Default : "info"
#   Value   : "debug","info","wran","error","fatal"
#
#log_level : "debug"

# Print log-string both file and STDOUT
#
#   Default : false
#
#log_stdout : true
```


How to Test
--------------
```
ruby -I lib test/cases/test_config.rb
ruby -I lib test/cases/test_cmd.rb
ruby -I lib test/cases/test_log.rb
```