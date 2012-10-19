How to use
=============

### Step1: make directory

```
$ mkdir bin log config
```

### Step2: make batch script with RBatch 

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

### Step3: Run batch script

```
$ ruby bin/backup.rb
```

### Step4: Check log file

```
$ cat log/YYYYMMDD_HHMMSS_backup.log

# Logfile created on 2012-10-20 00:19:23 +0900 by logger.rb/25413
I, [2012-10-20T00:19:23.422876 #2357]  INFO -- : start backup
I, [2012-10-20T00:19:23.424773 #2357]  INFO -- : {:stdout=>"", :stderr=>"cp: cannot stat `/var/log/message': No such file or directory\n", :status=>1}
E, [2012-10-20T00:19:23.424882 #2357] ERROR -- : backup failed
```