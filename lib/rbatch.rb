$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'digest'
require 'yaml'
module RBatch
  @@opt = {}
  @@rbatch_config = nil
  module_function
  def program_name       ; @@opt[:program_name] ; end
  def home_dir           ; @@opt[:home_dir] ; end
  def hostname           ; @@opt[:hostname] ; end
  def rbatch_config_path ; @@opt[:rbatch_config_path] ; end
  def rbatch_config      ; @@rbatch_config ; end

  def init
    @@opt[:program_name] = $PROGRAM_NAME
    @@opt[:home_dir] = ENV["RB_HOME"] ? ENV["RB_HOME"] : File.join(File.dirname(@@opt[:program_name]) , "..")
    case RUBY_PLATFORM
    when /mswin|mingw/
      @@opt[:hostname] =  ENV["COMPUTERNAME"] ? ENV["COMPUTERNAME"] : "unknownhost"
    when /cygwin|linux/
      @@opt[:hostname] = ENV["HOSTNAME"] ? ENV["HOSTNAME"] : "unknownhost"
    else
      @@opt[:hostname] = "unknownhost"
    end
    @@opt[:rbatch_config_path]=File.join(@@opt[:home_dir],"conf","rbatch.yaml")
    load_rbatch_config
  end
  def load_rbatch_config
    if File.exist?(@@opt[:rbatch_config_path])
      @@rbatch_config = YAML::load_file(@@opt[:rbatch_config_path])
      if @@rbatch_config == false
        @@rbatch_config = nil
      end
    else
      @@rbatch_config = nil
    end
  end
  def double_run_check
    # double run check
    if ( @@rbatch_config != nil && @@rbatch_config["forbid_double_run"] )
      lock_file="rbatch_lock_" + Digest::MD5.hexdigest(@@opt[:program_name])
      if Dir.exists? @@opt[:tmp_dir]
        Dir::foreach(@@opt[:tmp_dir]) do |f|
          if (Regexp.new(lock_file) =~ f)
            raise RBatchException, "Script double run is forbid about \"#{@@opt[:program_name]}\""
          end
        end
      end
      # make lockfile
      Tempfile::new(lock_file,@@opt[:tmp_dir])
    end
  end
end

# RBatch Exception
class RBatchException < Exception ; end

# main
RBatch::init

require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/common_config'
require 'rbatch/cmd'

RBatch::double_run_check
