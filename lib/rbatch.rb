$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

module RBatch
  @@program_name = $PROGRAM_NAME
  module_function
  def program_name=(f) ; @@program_name = f ; end
  def program_name ; @@program_name ; end
  def common_config
    path = File.join(File.dirname(RBatch.program_name),"..","config","rbatch.yaml")
    if File.exist?(path)
      return YAML::load_file(path)
    else
      return nil
    end
  end
end

require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/cmd'

