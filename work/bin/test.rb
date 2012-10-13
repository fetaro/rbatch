#!/usr/local/lib/ruby192/bin/ruby -I /home/fetaro/rbatch/lib

require 'rbatch/auto_logger'

RBatch::auto_logger{|log|
 log.info( "hoge" )
exception_hire
}
