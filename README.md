[[English]](https://github.com/fetaro/rbatch/blob/master/README.md "english") [[Japanese]](https://github.com/fetaro/rbatch/blob/master/README.ja.md "japanese")

RBatch:Ruby-base Simple Batch Framework
=============

About RBatch
--------------
This is Ruby-base Batch Script Framework. RBatch offers convenient functions, when you write batch scripts such as "data backup script" or "proccess starting script".

There are following functions. 

* Auto Logging
* Auto Mail Sending
* Auto Config Reading
* External Command Wrapper 
* Double Run Check


Note: RBatch works on Ruby 1.9.x or later, and on Ruby platform of "linux","mswin","mingw","cygwin".

### First

RBach has convention of file naming and directorory structure.

If you make "$RB_HOME/bin/hoge.rb", you should name config file to "$RB_HOME/conf/hoge.yaml". And the name of log file is decided on "$RB_HOME/log/YYYYMMDD_HHMMSS_hoge.rb"

For example
```
$RB_HOME/         <--- RBatch home
 |-bin            <--- Scripts
 |  |- A.rb
 |  |- B.rb
 |
 |-conf           <--- Configuration files
 |  |- A.yaml
 |  |- B.yaml
 |  |- rbatch.yaml  <--- RBatch global config
 |
 |-log            <--- Log files
    |- YYYYMMDD_HHMMSS_A.log
    |- YYYYMMDD_HHMMSS_B.log
```

Note: It is not necessary to define $RB_HOME as an environment variable. $RB_HOME is defined as "(running script path)/../"


### Auto Logging

Use "Auto Logging block", RBatch automatically writes to logfile.
The default location of log file is $RB_HOME/log/YYYYMMDD_HHMMSS_${PROG_NAME}.log .
If an exception occuerd, then RBatch write a stack trace to logfile.

sample

script : $RB_HOME/bin/sample1.rb
```
require 'rbatch'

RBatch::Log.new(){ |log|  # Logging block
  log.info "info string"
  log.error "error string"
  raise "exception"
}
```

logfile : $RB_HOME/log/20121020_005953_sample1.log
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

### Auto Mail Sending

By using "log_send_mail" option, when an error occurs in script, RBatch sends an error-mail automatically. 


### Auto Config Reading

By using RBatch, your script read a configuration file easily.
First you make configuration file which is named "(script base name).yaml" ,
Then, put it to $RB_HOME/conf/ .
So your script read it automatically.

sample

config : $RB_HOME/conf/sample2.yaml
```
key: value
array:
 - item1
 - item2
 - item3
```

script : $RB_HOME/bin/sample2.rb
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

If you can use common configuration file which is read from all scripts,
you make "$RB_HOME/conf/common.yaml" .

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

### Double Run Check

Using "forbid_double_run" option, you forbit double run of the RBatch script.


Quick Start
--------------

    $ sudo gem install rbatch
    $ rbatch-init    # => make directories and sample scripts
    $ ruby bin/hello_world.rb
    $ cat log/YYYYMMDD_HHMMSS_hello_world.log

Option
--------------

The optional designated way has following two in RBatch.

1. Global configuration file (conf/rbatch.yaml)
2. Argument of the constructer

If you write an option to the global configuration file, all scripts are effective. On the other hand, if you set it in the argument of the constructer, there is an effect in only the instance.

When the same option is set, the argument of the constructer is given priority to over the global configuration.

The name of the key to global configuration file and the name of the key to constructer option have correspondency. The key name in global configuration file is "(class name)_(key name)".

#### Set by Grobal Configuration File

If you make follow config file, option value effect to all scripts.

```
$RB_HOME/conf/rbatch.yaml
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
#   <data> --> Replace to YYYYMMDD date string
#   <time> --> Replace to HHMMSS time string
#   <prog> --> Replace to Program file base name (except extention).
#   <host> --> Replace to Hostname.
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
#log_send_mail : true

# Send mail parameters
#
#log_mail_to   : "xxx@sample.com"
#log_mail_from : "xxx@sample.com"
#log_mail_server_host : "localhost"
#log_mail_server_port : 25

```

### Set by argument of the constracter

#### class RBatch::Log 

    RBatch::Log.new(opt = nil)
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

#### class RBatch::Cmd

    RBatch::Log.new(cmd_str, opt = nil)
    opt = {
          :raise     => false,
          :timeout   => 0
          }
