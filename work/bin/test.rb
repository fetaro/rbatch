#!/usr/local/lib/ruby192/bin/ruby -I /root/rbatch/lib

require 'rbatch/auto_logger'

RBatch::Log::record({:output_dir => "../work"}){|log|
 log.info( "hoge" )
  #exception_hire
}
