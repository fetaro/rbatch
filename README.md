[[English]](https://github.com/fetaro/rbatch/blob/master/README.md "english") [[Japanese]](https://github.com/fetaro/rbatch/blob/master/README.ja.md "japanese")

RBatch:Ruby-base Batch-Script Framework
=============

About RBatch
--------------

RBatch is Ruby-base Batch Script Framework. RBatch has many fanctions to help with your making a batch script such as "data backup" or "proccess starting".

There are following functions. 

* Auto Logging
* Auto Mail Sending
* Auto Config Reading
* External Command Wrapper 
* Double Run Check


Note: RBatch works on Ruby 1.9.

Note: This software is released under the MIT License, see LICENSE.txt.

Quick Start
--------------

    $ sudo gem install rbatch
    $ rbatch-init    # => make directories and sample scripts
    $ ruby bin/hello_world.rb
    $ cat log/YYYYMMDD_HHMMSS_hello_world.log

Manual
--------------

### RBatch home directory

When you set ${RB_HOME} environment variable, RBatch home directory is fix at ${RB_HOME}.

When you do NOT set ${RB_HOME}, ${RB_HOME} is the parent directory of the directory which script is located at. In other words, default of ${RB_HOME} is "(script path)/../" .

### Directory Structure and Naming Convention

RBach has convention of file naming and directorory structure.

If you make a script on "${RB_HOME}/bin/hoge.rb", script's config file is "${RB_HOME}/conf/hoge.yaml" , and log file is "${RB_HOME}/log/YYYYMMDD_HHMMSS_hoge.rb".

For example
```
${RB_HOME}/         <--- RBatch home
 |
 |-.rbatchrc      <--- RBatch Run Conf
 |
 |-bin            <--- Scripts
 |  |- A.rb
 |  |- B.rb
 |
 |-conf           <--- Configuration files
 |  |- A.yaml
 |  |- B.yaml
 |
 |-log            <--- Log files
    |- YYYYMMDD_HHMMSS_A.log
    |- YYYYMMDD_HHMMSS_B.log
```

### Auto Logging

Use "Auto Logging block", RBatch automatically writes to logfile.
The default location of log file is ${RB_HOME}/log/YYYYMMDD_HHMMSS_${PROG_NAME}.log .
If an exception occuerd, then RBatch write a stack trace to logfile.

sample

script : ${RB_HOME}/bin/sample1.rb
```
require 'rbatch'

RBatch::Log.new(){ |log|  # Logging block
  log.info "info string"
  log.error "error string"
  raise "exception"
}
```

logfile : ${RB_HOME}/log/20121020_005953_sample1.log
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
If you make configuration file which is located ${RB_HOME}/conf/"(program base name).yaml", this file is read automatically.

sample

config : ${RB_HOME}/conf/sample2.yaml
```
key: value
array:
 - item1
 - item2
 - item3
```

script : ${RB_HOME}/bin/sample2.rb
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
you make "${RB_HOME}/conf/common.yaml" .

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

Using "forbid_double_run: true" option, two same name scripts cannot run at the same time. 

Customize
--------------

If you want to customize RBatch, you have two methods.

(1) Write Run-Conf (${RB_HOME}/.rbatchrc).
(2) Pass an option object to constructor in your script.

When an option is set in both (1) and (2), (2) is prior to (1).

#### Customize by writing Run-Conf (.rbatchrc)

If you make a follow config file, configurations effect to all scripts.

    ${RB_HOME}/.rbatchrc

Run-Conf Sample
```
# RBatch Run-Conf (.rbatchrc)
#
#   This format is YAML.
#

# -------------------
# Global setting
# -------------------

# Conf Directory
#
#   Default is "<home>/conf"
#
#   <home> is replaced to ${RB_HOME}
#
#conf_dir: <home>/config
#conf_dir: /etc/rbatch/

# Common config file name
#
#   Default is "common.yaml"
#
#common_conf_name: share.yaml

# Forbit Script Double Run
#
#   Default is false.
#   If this option is true, two same name scripts cannot run at the same time. 
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

# Command Timeout
#
#   Default is 0 [sec].
#
#cmd_timeout: 5

# -------------------
# Log setting
# -------------------

# Log Directory
#
#   Default is "<home>/log"
#
#   <home> is replaced to ${RB_HOME}
#
#log_dir: <home>/rb_log
#log_dir: /var/log/rbatch/

# Log File Name
#
#   Default is "<date>_<time>_<prog>.log".
#   Reservation words are follows.
#   <data> is replaced to YYYYMMDD date string
#   <time> is replaced to HHMMSS time string
#   <prog> is replaced to Program file base name (except extention).
#   <host> is replaced to Hostname.
#
#log_name : "<date>_<time>_<prog>.log"
#log_name : "<date>_<prog>.log"

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

# Print log string both file and STDOUT
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

# Mail parameters
#
#log_mail_to   : "xxx@sample.com"
#log_mail_from : "xxx@sample.com"
#log_mail_server_host : "localhost"
#log_mail_server_port : 25

```

### Customize by passing option object to constructor

If you want to set options in a script, you hand an argument of options to a constructor.

#### class RBatch::Log 

    opt = {
          :name      => "<date>_<time>_<prog>.log",
          :dir       => "/var/log",
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

#### class RBatch::Cmd

    opt = {
          :raise     => false,
          :timeout   => 0
          }

    RBatch::Log.new(cmd_str, opt)
