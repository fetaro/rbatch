require 'rbatch'
#RBatch::Log.verbose=true
RBatch::Log.new({ :quiet => true } ) do |log|
  log.delete_old_log
p "--"
  log.delete_old_log 1
p "--"
  log.delete_old_log 2
p "--"
  log.delete_old_log 3

end
