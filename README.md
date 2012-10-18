* How to use


```
require 'rbatch'

RBatch::Log.new(){|log|
  log.info( "start backup" )
  result = RBatch::run( "cp -p /var/log/message /backup")
  log.info( result )
  log.error ( "backup fail") if result[:status] != 0
}

```
