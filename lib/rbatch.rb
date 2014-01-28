$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rbatch/controller'

module RBatch
  @@ctrl = nil
  module_function
  def init
    @@ctrl = RBatch::Controller.new
  end
  # @return [RBatch::Controller]
  def ctrl ; @@ctrl ; end

  # @return [RBatch::Variables]
  def vars ; @@ctrl.vars ; end

  # Read config file.
  # @raise [RBatch::ConfigException]
  # @return [RBatch::Config]
  def config               ; @@ctrl.config ; end

  # Read common config file.
  # @raise [RBatch::ConfigException]
  # @return [RBatch::Config]
  def common_config        ; @@ctrl.common_config ; end

  # External command wrapper
  # @param [String] cmd_str command string such as "ls -l"
  # @option opt [Boolean] :raise
  # @option opt [Integer] :timeout
  # @raise [RBatch::CmdException]
  # @return [RBatch::CmdResult]
  def cmd(cmd_str,opt=nil) ; @@ctrl.cmd(cmd_str,opt) ; end
end

# main
RBatch::init

