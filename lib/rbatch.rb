$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rbatch/controller'

module RBatch
  @@ctrl = nil
  module_function
  def init
    @@ctrl = RBatch::Controller.new
  end
  def ctrl ; @@ctrl ; end
  def vars ; @@ctrl.vars ; end
  def config               ; @@ctrl.config ; end
  def common_config        ; @@ctrl.common_config ; end
  def cmd(cmd_str,opt=nil) ; @@ctrl.cmd(cmd_str,opt) ; end
end

# main
RBatch::init

