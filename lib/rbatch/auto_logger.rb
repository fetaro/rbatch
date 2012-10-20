require 'logger'
require 'pathname'

module RBatch
  class Log
    @@verbose = false

    # Set verbose mode flag.
    def Log.verbose=(bol); @@verbose = true ; end
    # Get verbose mode flag.
    def Log.verbose ; @@verbose ; end

    # Auto Logging Block.
    # 
    # ==== Sample
    #  RBatch::Log.new({:level => Logger::INFO}){ |log|
    #    log.info "info string"
    #    log.error "error string"
    #    raise "exception"
    #  }
    #
    # ==== Params
    # +opt+ = Option hash object. Hash keys is follows.
    # - +:file_prefix+ (String) = log filename prefix format. Default is "%Y%m%d_%H%M%S_".
    # - +:output_dir+ (String) = log direcotry path. Default is "../log"
    # - +:path+ (String) = log file path. Default is {output_dir} + {file_prefix} + (Program name) + ".log"
    # - +:formatter+ (String) = log formatter. "Logger#formatter= "
    # - +:level+ (Logger::[DEBUG|INFO|WARN|ERROR|FATAL])= log level. Default is Logger::INFO
    # 
    # ==== Block params
    # +log+ = Instance of +Logger+
    def initialize(opt = nil)
      file_prefix = "%Y%m%d_%H%M%S_"
      output_dir  = File.join(File.dirname(RBatch.program_name), ".." , "log")
      path        = nil
      formatter   = nil
      level       = Logger::INFO
      if ! opt.nil?
        file_prefix = opt[:file_prefix] if opt[:file_prefix]
        output_dir  = opt[:output_dir]  if opt[:output_dir]
        path        = opt[:path]        if opt[:path]
        formatter   = opt[:formatter]   if opt[:formatter]
        level       = opt[:level]   if opt[:level]
      end
      if path.nil?
        file = Time.now.strftime(file_prefix) + Pathname(File.basename(RBatch.program_name)).sub_ext(".log").to_s
        path = File.join(output_dir,file)
      end
      puts "Logfile Path = " + path if @@verbose
      puts "RBatch.program_name = " + RBatch.program_name if @@verbose
      log = Logger.new(path)
      log.formatter = formatter if formatter
      log.level = level
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

