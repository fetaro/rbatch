$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'digest'
module RBatch
  @@program_name = $PROGRAM_NAME
  module_function
  def program_name=(f) ; @@program_name = f ; end
  def program_name ; @@program_name ; end
  # Hostname
  def hostname
    case RUBY_PLATFORM
    when /mswin|mingw/
      return ENV["COMPUTERNAME"] ? ENV["COMPUTERNAME"] : "unknownhost"
    when /cygwin|linux/
      return ENV["HOSTNAME"] ? ENV["HOSTNAME"] : "unknownhost"
    else
      return "unknownhost"
    end
  end
  # tmp dir
  def tmp_dir
    case RUBY_PLATFORM
    when /mswin|mingw/
      if ENV["TEMP"].nil?
        raise "Cannot use temporary directory, because ENV[\"TEMP\"] is not defined"
      else
        return ENV["TEMP"]
      end
    when /cygwin|linux/
      return ENV["TMPDIR"] ? ENV["TMPDIR"] : "/tmp"
    else
      if ENV["TMPDIR"].nil? && ENV["TEMP"].nil?
        raise "Unknown RUBY_PRATFORM : " + RUBY_PLATFORM
      else
        return ENV["TMPDIR"] || ENV["TEMP"]
      end
    end
  end
  def rbatch_config_path
    File.join(File.dirname(RBatch.program_name),"..","conf","rbatch.yaml")
  end
  def rbatch_config
    if File.exist?(RBatch.rbatch_config_path)
      yaml = YAML::load_file(RBatch.rbatch_config_path)
      if yaml
        return yaml
      else
        # If file is emply , YAML::load_file is false
        return nil
      end
    else
      return nil
    end
  end
  def double_run_check
    # double run check
    if ( RBatch::rbatch_config != nil && RBatch::rbatch_config["forbid_double_run"] )
      lock_file="rbatch_lock_" + Digest::MD5.hexdigest(@@program_name)
      if Dir.exists? RBatch::tmp_dir
        Dir::foreach(RBatch::tmp_dir) do |f|
          if (Regexp.new(lock_file) =~ f)
            raise RBatchException, "Script double run is forbid about \"#{RBatch::program_name}\""
          end
        end
      end
      # make lockfile
      Tempfile::new(lock_file,RBatch::tmp_dir)
    end
  end

  def double_run_lock_file ;  ; end
end

# RBatch Exception
class RBatchException < Exception ; end

# main
require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/common_config'
require 'rbatch/cmd'

RBatch::double_run_check
