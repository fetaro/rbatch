require 'yaml'
require 'pathname'

module RBatch

  module_function

  def read_config
    file = Pathname(File.basename(RBatch.program_name)).sub_ext(".yaml").to_s
    dir = File.join(File.join(File.dirname(RBatch.program_name),".."),"config")
    return YAML::load_file(File.join(dir,file))
  end

end

