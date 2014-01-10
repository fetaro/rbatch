require 'rbatch'

RBatch::Log.new do |log|
  if ARGV.size != 2
    raise "Argument ERROR: Usage: ruby store_to_openidm.rb (category) (file)"
  end
  category=ARGV[0]
  filepath=ARGV[1]
  store_file_to_openidm(category,filepath,log)
end
