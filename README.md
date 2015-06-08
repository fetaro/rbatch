

[English](https://github.com/fetaro/rbatch/blob/master/README.md
"english") | [Japanese
](https://github.com/fetaro/rbatch/blob/master/README.ja.md
"japanese") |  [Document
(YardDoc)](http://fetaro.github.io/rbatch/index.html)

[![Gem Version](https://badge.fury.io/rb/rbatch.svg)](http://badge.fury.io/rb/rbatch)
[![Build Status](https://travis-ci.org/fetaro/rbatch.svg?branch=master)](https://travis-ci.org/fetaro/rbatch)
RBatch: Batch Script Framework
=============

About RBatch
--------------

RBatch is a ruby-based framework for batch scripts. RBatch help to
make batch scripts such as "data backup" or "proccess controll ".

There are following functions:

* Auto Logging
* Auto Library Loading
* Auto Mail Sending
* Auto Config Reading
* External Command Wrapper
* Double Run Check

Note: RBatch works on Ruby 1.9 above.

Note: This software is released under the MIT License, see LICENSE.txt.

Quick Start
--------------

    $ sudo gem install rbatch
    $ rbatch-init    # => make directories and sample scripts
    $ ruby bin/hello_world.rb
    $ cat log/YYYYMMDD_HHMMSS_hello_world.log

Overview
--------------

### RBatch home directory

If you set the `${RB_HOME}` as environment variable, RBatch home
directory is fixed at `${RB_HOME}`.
Otherwise, `${RB_HOME}` is the parent directory of the directory where
the script is located. In other words, default of `${RB_HOME}` is
`(script path)/../` .

### Directory Structure and File Naming Convention

RBatch is made based on the rule of "convention over configuration".
So there are conventions of file naming and directory structure.
If you follow these rules, you will gain plenty development
environment without any configurations.

The rules are below:

* Script should be `${RB_HOME}/bin/hoge.rb`
* Config file should be `${RB_HOME}/conf/hoge.yaml`
* Common config file should be `${RB_HOME}/conf/common.yaml`
* Libraries should be `${RB_HOME}/lib/*.rb`
* Log files should be `${RB_HOME}/log/YYYYMMDD_HHMMSS_hoge.log`

For example

    ${RB_HOME}         <--- RBatch home
     |
     |- .rbatchrc      <--- RBatch Run-Conf
     |
     |- bin            <--- Scripts
     |   |-  A.rb
     |   |-  B.rb
     |
     |- conf           <--- Config files
     |   |-  A.yaml    <--- Individual config file
     |   |-  B.yaml
     |   |-  common.yaml <--- Common config file
     |
     |- log            <--- Log files
     |   |-  YYYYMMDD_HHMMSS_A.log
     |   |-  YYYYMMDD_HHMMSS_B.log
     |
     |- lib            <--- Libraries
         |-  lib_X.rb
         |-  lib_Y.rb

### Auto Logging

By using the auto logging block ,`RBatch::Log`, RBatch automatically
output logfiles.
The default location of log files are
`${RB_HOME}/log/YYYYMMDD_HHMMSS_(script base).log`.
If exceptions are raised in auto logging block, RBatch will rescue it
and output its stack trace to the logfile.

Sample

Make script `${RB_HOME}/bin/sample1.rb`

```ruby
require 'rbatch'
RBatch::Log.new(){ |log|  # Logging block
  log.info "info string"
  log.error "error string"
  raise "exception"
}
```

Run script. Log file is `${RB_HOME}/log/20121020_005953_sample1.log`

    # Logfile created on 2012-10-20 00:59:53 +0900 by logger.rb/25413
    [2012-10-20 00:59:53 +900] [INFO ] info string
    [2012-10-20 00:59:53 +900] [ERROR] error string
    [2012-10-20 00:59:53 +900] [FATAL] Caught exception; existing 1
    [2012-10-20 00:59:53 +900] [FATAL] exception (RuntimeError)
        [backtrace] test.rb:6:in `block in <main>'
        [backtrace]
/usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in
`initialize'
        [backtrace] test.rb:3:in `new'
        [backtrace] test.rb:3:in `<main>'

### Auto Library Loading

If you make libraries at `${RB_HOME}/lib/*.rb`, these are
loaded(required) before scripts run.

### Auto Mail Sending

By using `log_send_mail` option, RBatch sends error messages by e-mail
when ERROR or FATAL level logs are raised.

### Auto Config Reading

By putting the configuration file as `${RB_HOME}/conf/"(script
base).yaml"`, the file is read and parsed automatically.

Sample

Make the config file `${RB_HOME}/conf/sample2.yaml`.

    key: value
    array:
     - item1
     - item2
     - item3

In script named `${RB_HOME}/bin/sample2.rb`, this config values can be used.

```ruby
require 'rbatch'

# You can read config value without loading file.
p RBatch.config["key"]   # => "value"
p RBatch.config["array"] # => ["item1", "item2", "item3"]

# If key does not exist, raise exception
p RBatch.config["not_exist"] # => Raise RBatch::ConfigException
```

#### Common Config

By putting shard config file at `${RB_HOME}/conf/common.yaml`, the
values in the file are shared by all scripts.
If you want to change the name of the config file, you cau use the
`common_conf_name` option.

### External Command Wrapper

RBatch have useful functions of external command execution. 
`RBatch.cmd` is wrapper of `Kernel.#Spawn`.

This function return a result object which contains command's string,
STDOUT, STDERR and exit status.

Sample

```ruby
require 'rbatch'

r = RBatch.cmd("ls")
p r.stdout # => "fileA\nfileB\n"
p r.stderr # => ""
p r.status # => 0
```

If you want to set a timeout of external command, you can use
`cmd_timeout` option.

By using `cmd_raise` option, if exit status is not 0,
RBatch raise an Exception.
This function help to handle the errors of external command.

### Double Run Check

By using `forbid_double_run` option, two scripts both has same name
cannot run at the same time.

Manual
--------------

Manual -> [Document (YardDoc)](http://fetaro.github.io/rbatch/index.html)

Sample
--------------

### AWS EC2 Volume Backup Script

First you make the configuration file.

Config File : `${RB_HOME}/conf/ec2_create_snapshot.yaml`

```
access_key : AKIAITHEXXXXXXXXX
secret_key : JoqJSdP8+tpdFYWljVbG0+XXXXXXXXXXXXXXX

```

Next, you write the script.

Script : `${RB_HOME}/bin/ec2_create_snapshot.rb`

```ruby
require 'rbatch'  # <= require rbatch
require 'aws-sdk'
require 'net/http'

RBatch::Log.new do |log| # <= Start Log block. And write main logic in
this block.
  # get ec2 region
  @ec2_region = "ec2." +
    Net::HTTP.get("169.254.169.254",
"/latest/meta-data/placement/availability-zone").chop +
    ".amazonaws.com"
  log.info("ec2 region : #{@ec2_region}")  # <= Output Log

  #create ec2 instance
  @ec2 = AWS::EC2.new(:access_key_id     =>
RBatch.config["access_key"],  # <= Read Config
                      :secret_access_key => RBatch.config["secret_key"],
                      :ec2_endpoint      => @ec2_region)


  # create instance
  @instance_id = Net::HTTP.get("169.254.169.254",
"/latest/meta-data/instance-id")
  @instance = @ec2.instances[@instance_id]
  log.info("instance_id : #{@instance_id}")

  # create snapshots
  @instance.block_devices.each do | dev |
    desc = @instance_id + " " + dev[:device_name] + " " +
      dev[:ebs][:volume_id] + " " +Time.now.strftime("%Y/%m/%d %H:%M").to_s
    log.info("create snapshot : #{desc}")
    @ec2.volumes[dev[:ebs][:volume_id]].create_snapshot(desc)
    log.info("sucess")
  end
end

```

Finally, you run the script, then following logfile is output.

Log file : `${RB_HOME}/log/20140121_123124_ec2_create_snapshot.log`

```
[2014-01-21 12:31:24 -0500] [INFO ] === START RBatch === (PID=10095)
[2014-01-21 12:31:24 -0500] [INFO ] RB_HOME : "/opt/MyProject"
[2014-01-21 12:31:24 -0500] [INFO ] Load Run-Conf: "/opt/MyProject/.rbatchrc"
[2014-01-21 12:31:24 -0500] [INFO ] Load Config  :
"/opt/MyProject/conf/ec2_create_snapshot.yaml"
[2014-01-21 12:31:24 -0500] [INFO ] Start Script :
"/opt/MyProject/bin/ec2_create_snapshot.rb"
[2014-01-21 12:31:24 -0500] [INFO ] Logging Start:
"/opt/MyProject/log/20140121_123124_ec2_create_snapshot.log"
[2014-01-21 12:31:24 -0500] [INFO ] ec2 region :
ec2.ap-northeast-1.amazonaws.com
[2014-01-21 12:31:25 -0500] [INFO ] instance_id : i-cc25f1c9
[2014-01-21 12:31:25 -0500] [INFO ] create snapshot : i-cc25f1c9
/dev/sda1 vol-82483ea7 2014/01/21 12:31
[2014-01-21 12:31:25 -0500] [INFO ] sucess
```

Only you write a short code, this batch script has logging and
reading config function.

Customize
--------------
If you want to customize RBatch, you have two methods.

* (1) Write Run-Conf(`${RB_HOME}/.rbatchrc`).
* (2) Pass an option object to constructor of RBatch classes in a script.

When an option is set in both (1) and (2), (2) is prior to (1).

#### Customize by writing Run-Conf (.rbatchrc)

Sample of RBatch Run-Conf `${RB_HOME}/.rbatchrc`.

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
#   <home> is replaced to ${RB_HOME}
#
#conf_dir : <home>/config/
#conf_dir : /etc/rbatch/

# Common Config file name
#
#   Default is "common.yaml"
#
#common_conf_name : share.yaml

# Library Directory
#
#   Default is "<home>/lib"
#   <home> is replaced to ${RB_HOME}
#
#lib_dir: /usr/local/lib/rbatch/

# Auto Library Load
#
#   Default is true
#   If true, require "(library directory)/*.rb" before script run.
#
#auto_lib_load : true
#auto_lib_load : false

# Forbit Script Running Doubly
#
#   Default is false.
#   If true, two same name scripts cannot run at the same time.
#
#forbid_double_run: true
#forbid_double_run: false

# RBatch Journal Level
#
#   Default is 1
#   RBatch Journal is message of RBatch and is output to STDOUT.
#   If 2, put much more information.
#   If 0, put nothing.
#
#   Example of RBatch Journal are follows.
#     [RBatch] === START RBatch === (PID=5795)
#     [RBatch] RB_HOME : "/path/to/"
#     [RBatch] Load Run-Conf: "/path/to/.rbatchrc"
#     [RBatch] Start Script : "/path/to/bin/hello.rb"
#     ....
#
#rbatch_journal_level : 2
#rbatch_journal_level : 0

# Mix RBatch Journal to Logs
#
#   Default is true.
#   If true, RBatch Journal is output not only STDOUT
#   but also log file(s) which is(are) opened at time.
#
#mix_rbatch_journal_to_logs : true
#mix_rbatch_journal_to_logs : false

# -------------------
# Log setting
# -------------------

# Log Directory
#
#   Default is "<home>/log"
#   <home> is replaced to ${RB_HOME}
#
#log_dir : <home>/rb_log
#log_dir : /var/log/rbatch/

# Log File Name
#
#   Default is "<date>_<time>_<prog>.log".
#   <data> is replaced to YYYYMMDD date string
#   <time> is replaced to HHMMSS time string
#   <prog> is replaced to Program file base name (except extention).
#   <host> is replaced to Hostname.
#
#log_name : "<date>_<time>_<prog>.log"
#log_name : "<date>_<prog>.log"

# Append Log
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
#log_level : "warn"

# Print log string both log file and STDOUT
#
#   Default is false.
#
#log_stdout : true
#log_stdout : false

# Delete old log files
#
#   Default is false.
#   If this is true, delete old log files when RBatch::Log.new is called.
#   If log filename format does not include "<date>", do nothing.
#
#log_delete_old_log : true
#log_delete_old_log : false

# Expire Days of Log Files
#
#   Default is 7.
#
#log_delete_old_log_date : 14

# Log buffering
#
#   Default is false.
#   If true, log output is bufferd.
#
#log_bufferd : true
#log_bufferd : false

# Output Exit Status
#
#   Default is true.
#   When you use the "exist" method in a log block,
#   output exit status into the log file.
#
#log_output_exit_status : true
#log_output_exit_status : false

# Send Mail
#
#   Default is false.
#   When log.error is called, log.fatal is called,
#   or rescue an Exception, send e-mail.
#
#log_send_mail : true

# Mail Parameters
#
#log_mail_to   : "xxx@sample.com"
#log_mail_from : "xxx@sample.com"
#log_mail_server_host : "localhost"
#log_mail_server_port : 25
#
# if you want to send multiple recipients, use array.
#
#log_mail_to :
#  - "AAA@sample.com"
#  - "BBB@sample.com"

# -------------------
# Cmd setting
# -------------------

# Raise Exception
#
#   Default is false.
#   If true, when command exit status is not 0, raise exception.
#
#cmd_raise : true
#cmd_raise : false

# Command Timeout
#
#   Default is 0 [sec] (=no timeout).
#
#cmd_timeout : 5


```

### Customize by passing option object to constructor

If you want to change options in a script, you pass an options object
to the constructor of RBatch::Log or RBatch::Cmd.

#### option of RBatch::Log

Sumple

```ruby
opt = {
      :name      => "<date>_<time>_<prog>.log",
      :dir       => "/var/log",
      :append    => true,
      :level     => "info",
      :stdout    => false,
      :delete_old_log => false,
      :delete_old_log_date => 7,
      :bufferd => false,
      :output_exit_status => true,
      :send_mail => false,
      :mail_to   => nil,
      :mail_from => "rbatch.localhost",
      :mail_server_host => "localhost",
      :mail_server_port => 25
      }
RBatch::Log.new(opt)
```

#### option of RBatch::Cmd

Sample

```ruby
opt = {
      :raise     => false,
      :timeout   => 0
      }
RBatch::Cmd.new("ls -l", opt).run
```

Migration from version 1 to version 2
--------------

Move `${RB_HOME}/conf/rbatch.yaml` to `${RB_HOME}/.rbatchrc` .


