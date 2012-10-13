require 'yaml'
require 'pathname'

module RBatch
  @@config = nil

  module_function

  def read_config
    file = Pathname(File.basename($0)).sub_ext(".yaml").to_s
    dir = File.join(File.join(File.dirname($0),".."),"config")
    @@config = YAML::load_file(File.join(dir,file))
  end

  def config
    @@config
  end

end

