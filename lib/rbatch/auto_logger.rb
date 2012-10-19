require 'logger'
require 'pathname'

module RBatch
  class Log
    @@debug = false

    def Log.debug=(bol); @@debug = true ; end
    def Log.debug ; @@debug ; end

    #
    # param: option
    #  :file_prefix
    #  :output_dir
    #  :path
    #  :formatter   : input directory to "Logger#formatter= "
    def initialize(opt = nil)
      file_prefix = "%Y%m%d_%H%M%S_"
      output_dir  = File.join(File.dirname(RBatch.program_name), ".." , "log")
      path        = nil
      formatter   = nil
      if ! opt.nil?
        file_prefix = opt[:file_prefix] if opt[:file_prefix]
        output_dir  = opt[:output_dir]  if opt[:output_dir]
        path        = opt[:path]        if opt[:path]
        formatter   = opt[:formatter]   if opt[:formatter]
      end
      if path.nil?
        file = Time.now.strftime(file_prefix) + Pathname(File.basename(RBatch.program_name)).sub_ext(".log").to_s
        path = File.join(output_dir,file)
      end
      puts "Logfile Path = " + path if @@debug
      puts "RBatch.program_name = " + RBatch.program_name if @@debug
      log = Logger.new(path)
      log.formatter = formatter if formatter
      begin
        yield log
      rescue => e
        log.fatal("Caught exception; existing 1")
        log.fatal(e)
        exit 1
      ensure
        log.close
      end
    end
  end
end

