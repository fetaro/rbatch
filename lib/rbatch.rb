$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'digest'
require 'yaml'

module RBatch
  @@home_dir = nil
  @@run_conf = nil
  @@tmp_dir = nil

  module_function

  def program_name       ; $PROGRAM_NAME ; end
  def home_dir           ; @@home_dir ; end
  def home_dir=(d)       ; @@home_dir=d ; end
  def rbatch_config      ; @@rbatch_config ; end
  def rbatch_config=(f)  ; @@rbatch_config=f ; end
  def run_conf           ; @@run_conf ; end
  def init
    @@home_dir = ENV["RB_HOME"] ? ENV["RB_HOME"] : File.join(File.dirname(@@program_name) , "..")
    @@run_conf = RunConf.new(File.join(@@home_dir,".rbatchrc"))
  end
  def reload_run_conf
    @@run_conf = RunConf.new(File.join(@@home_dir,".rbatchrc"))
  end
  def double_run_check
    # double run check
    if ( @@run_conf[:forbid_double_run] )
      lock_file="rbatch_lock_" + Digest::MD5.hexdigest(@@program_name)
      if Dir.exists? @@run_conf[:tmp_dir]
        Dir::foreach(@@run_conf[:tmp_dir]) do |f|
          if (Regexp.new(lock_file) =~ f)
            raise RBatchException, "Script double run is forbid about \"#{@@program_name}\""
          end
        end
      end
      # make lockfile
      Tempfile::new(lock_file,@@run_conf[:tmp_dir])
    end
  end
end

# RBatch Exception
class RBatchException < Exception ; end

# main
require 'rbatch/run_conf'
require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/common_config'
require 'rbatch/cmd'

RBatch::init
RBatch::double_run_check
