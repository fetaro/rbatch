require 'logger'
require 'pathname'

module RBatch
  module Log
    module_function

    @@debug = false
    def debug=(bol) ; @@debug=bol ; end
    def debug ; @@debug ; end

    @@file_prefix = "%Y%m%d_%H%M%S_"
    def file_prefix=(str) ; @@file_prefix=str ; end
    def file_prefix ;       @@file_prefix ; end

    @@output_dir = File.join(File.dirname($0), "..", "log")
    def output_dir=(str) ; @@output_dir=str ; end
    def output_dir ;       @@output_dir ; end

    def record(opt = nil)
      file_prefix = @@file_prefix
      output_dir = @@output_dir
      if ! opt.nil?
        file_prefix = opt[:file_prefix] if opt[:file_prefix]
        output_dir = opt[:output_dir] if opt[:output_dir]
      end

      file = Time.now.strftime(file_prefix) + Pathname(File.basename($0)).sub_ext(".log").to_s
      log = Logger.new(File.join(output_dir,file))
      puts "Logfile Path = " + File.join(output_dir,file) if debug
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

