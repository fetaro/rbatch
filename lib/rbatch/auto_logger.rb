require 'logger'
require 'pathname'

module RBatch
  module Log
    module_function
    @@default_file_prefix = "%Y%m%d_%H%M%S_"
    @@default_output_dir  = File.join(File.dirname($0), "..", "log")
    @@default_path        = nil
    @@default_debug       = false

    @@file_prefix   = @@default_file_prefix
    @@output_dir    = @@default_output_dir
    @@path          = @@default_path
    @@debug         = @@default_debug

    def reset
      @@file_prefix   = @@default_file_prefix
      @@output_dir    = @@default_output_dir
      @@path          = @@default_path
      @@debug         = @@default_debug
    end

    def file_prefix=(str) ; @@file_prefix=str ; end
    def file_prefix ;       @@file_prefix ; end

    def output_dir=(str) ; @@output_dir=str ; end
    def output_dir ;       @@output_dir ; end

    def path=(str) ; @@path=str ; end
    def path ;       @@path ; end

    def debug=(bol) ; @@debug=bol ; end
    def debug ;       @@debug ; end

    def record(opt = nil)
      file_prefix = @@file_prefix
      output_dir = @@output_dir
      path = @@path
      if ! opt.nil?
        file_prefix = opt[:file_prefix] if opt[:file_prefix]
        output_dir = opt[:output_dir] if opt[:output_dir]
        path = opt[:path] if opt[:path]
      end
      if path.nil?
        file = Time.now.strftime(file_prefix) + Pathname(File.basename($0)).sub_ext(".log").to_s
        path = File.join(output_dir,file)
      end
      puts "Logfile Path = " + path if debug
      log = Logger.new(path)
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

