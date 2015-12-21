$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rbatch/controller'

module RBatch
  # @private
  @@ctrl = nil

  module_function

  # @private
  def init
    @@ctrl = RBatch::Controller.new
    @@ctrl.load_lib
  end

  # @private
  def ctrl ; @@ctrl ; end

  # @private
  def vars ; @@ctrl.vars ; end

  # Return Config Object
  # @raise [RBatch::ConfigException]
  # @return [RBatch::Config]
  # @example RB_HOME/conf/hoge.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # @example ${RB_HOME}/bin/hoge.rb
  #   p RBatch.config["key"]   # => "value"
  #   p RBatch.config["array"] # => ["item1", "item2", "item3"]
  #   p RBatch.config["not_exist"] # => Raise RBatch::ConfigException
  def config               ; @@ctrl.config ; end

  # Return Common-Config Object
  # @raise [RBatch::ConfigException]
  # @return [RBatch::Config]
  # @example RB_HOME/conf/common.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # @example ${RB_HOME}/bin/hoge.rb
  #   p RBatch.common_config["key"]   # => "value"
  #   p RBatch.common_config["array"] # => ["item1", "item2", "item3"]
  #   p RBatch.common_config["not_exist"] # => Raise RBatch::ConfigException
  def common_config        ; @@ctrl.common_config ; end

  # Shortcut of RBatch::Cmd.new(cmd_str,opt).run
  # @see RBatch::Cmd
  # @example
  #   r = RBatch.cmd("ls")
  #   p r.stdout # => "fileA\nfileB\n"
  #   p r.stderr # => ""
  #   p r.status # => 0
  # @example
  #   r = RBatch.cmd("rsync /foo /bar",{:timeout => 10})
  def cmd(cmd_str,opt=nil) ; @@ctrl.cmd(cmd_str,opt) ; end
end

# main
RBatch::init

