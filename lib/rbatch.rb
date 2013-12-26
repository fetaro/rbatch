$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'yaml'

module RBatch
  @@program_name = $PROGRAM_NAME
  @@home_dir = nil
  @@run_conf_path = nil
  @@run_conf = nil
  module_function
  def program_name  ; @@program_name ; end
  def home_dir      ; @@home_dir ; end
  def run_conf_path ; @@run_conf_path ; end
  def run_conf      ; @@run_conf ; end
  def init
    if  ENV["RB_HOME"]
      @@home_dir = ENV["RB_HOME"]
    else
      @@home_dir =  File.join(File.dirname(@@program_name) , "..")
    end
    @@run_conf_path = File.join(@@home_dir,"conf","rbatch.yaml")
    @@run_conf = RunConf.new(@@run_conf_path,@@home_dir)
  end
end

# main
require 'rbatch/run_conf'
require 'rbatch/double_run_checker'

RBatch::init

if ( @@run_conf[:forbid_double_run] )
  RBatch::DoubleRunChecker.check(@@program_name) #raise error if check is NG
  RBatch::DoubleRunChecker.make_lock_file(@@program_name)
end

require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/common_config'
require 'rbatch/cmd'
