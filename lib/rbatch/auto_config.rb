require 'yaml'
require 'pathname'

module RBatch

  module_function

  # Read config file and return hash opject.
  # 
  # Default config file path is "../config/(Program name).yaml"
  # ==== Sample
  # config : ./config/sample2.yaml
  #  key: value
  #  array:
  #   - item1
  #   - item2
  #   - item3
  # script : ./bin/sample2.rb
  #  require 'rbatch'
  #  p RBatch::read_config
  #  => {"key" => "value", "array" => ["item1", "item2", "item3"]}
  def read_config
    file = Pathname(File.basename(RBatch.program_name)).sub_ext(".yaml").to_s
    dir = File.join(File.join(File.dirname(RBatch.program_name),".."),"config")
    return YAML::load_file(File.join(dir,file))
  end

end

