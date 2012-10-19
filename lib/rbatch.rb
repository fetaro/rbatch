$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

module RBatch
  @@program_name = $PROGRAM_NAME
  module_function
  def program_name=(f) ; @@program_name = f ; end
  def program_name ; @@program_name ; end
end

require 'rbatch/auto_logger'
require 'rbatch/auto_config'
require 'rbatch/runcher'

