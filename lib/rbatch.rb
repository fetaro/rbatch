$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'yaml'

module RBatch
  @@ctrl = nil
  module_function
  def init
    @@ctrl = RBatch::Controller.new
  end
  def ctrl
    @@ctrl
  end
  def run_conf
    @@ctrl.run_conf
  end
  def run_conf_path ; @@ctrl.run_conf_path ; end

  # Config Reader
  #
  # Read config file and return hash opject. If the key does not exist in config file, raise RBatch::Config::Exception.
  # 
  # Default config file path is "${RB_HOME}/conf/(program base name).yaml"
  # ==== Sample
  # config : ${RB_HOME}/conf/sample2.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # script : ${RB_HOME}/bin/sample2.rb
  #  require 'rbatch'
  #  p RBatch::Config.new
  #  # or  p RBatch::config
  #  => {"key" => "value", "array" => ["item1", "item2", "item3"]}
  def config ; @@ctrl.config ; end
  def common_config ; @@ctrl.common_config ; end
  def journal(a,b) ; @@ctrl.journal(a,b) ; end
end

# main
require 'rbatch/controller'
require 'rbatch/run_conf'
require 'rbatch/double_run_checker'
require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/cmd'

RBatch::init

