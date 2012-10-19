RBatch:Ruby-base Batch Script Framework
=============

About RBatch
--------------
This is a Ruby-base Batch Script Framework.
There are 3 functions. 
* Auto Logging
* Auto Read Config
* External Command Wrapper 

### Auto Logging
* Auto Logging block
 * Use Auto Logging block, RBatch output log to logfile (default is "../log/YYYYMMDD-HHMMSS.log") automaticaly
* Exception catch
 * If exception occuerd, then RBatch write stack trace to log file

sample script (./bin/rbatch.rb)
```
require 'rbatch'

RBatch::Log.new(){ |log|  # Logging block
  log.info( "start backup" )
  result = RBatch::run( "cp -p /var/log/message /backup")
  log.info( result )
  log.error ( "backup failed") if result[:status] != 0
}
```

output log (./log/YYYYMMDD-HHMMSS.log)
```
# Logfile created on 2012-10-20 00:19:23 +0900 by logger.rb/25413
I, [2012-10-20T00:19:23.422876 #2357]  INFO -- : start backup
I, [2012-10-20T00:19:23.424773 #2357]  INFO -- : {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
E, [2012-10-20T00:19:23.424882 #2357] ERROR -- : backup failed
```

* RBatch read config file (default is "../config/progname.yaml")


Quick Start
--------------
### Step1: Install

```
# git clone git@github.com:fetaro/rbatch.git
# cd rbatch
# rake package
# gem install pkg/rbatch-1.0.0
```

### Step2: Make directories

```
$ mkdir bin log
```

### Step3: Write batch script with RBatch 

for bin/backup.rb
```
require 'rbatch'

RBatch::Log.new(){|log|
  log.info( "start backup" )
  result = RBatch::run( "cp -p /var/log/message /backup")
  log.info( result )
  log.error ( "backup failed") if result[:status] != 0
}
```

### Step4: Run batch script

```
$ ruby bin/backup.rb
```

### Step5: Check log file

```
$ cat log/YYYYMMDD_HHMMSS_backup.log

# Logfile created on 2012-10-20 00:19:23 +0900 by logger.rb/25413
I, [2012-10-20T00:19:23.422876 #2357]  INFO -- : start backup
I, [2012-10-20T00:19:23.424773 #2357]  INFO -- : {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
E, [2012-10-20T00:19:23.424882 #2357] ERROR -- : backup failed
```