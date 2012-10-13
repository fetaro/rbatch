require 'logger'
require 'pathname'

module RBatch
  module_function
  def auto_logger
    file = Time.now.strftime("%Y%m%d_%H%M%S_") + Pathname(File.basename($0)).sub_ext(".log").to_s
    dir = File.join(File.join(File.dirname($0),".."),"log")
    log = Logger.new(File.join(dir,file))
    begin
      yield log
    rescue => e
      log.fatal("Caught exception; existing 1")
      log.fatal(e)
      exit 1
    end
  end
end

