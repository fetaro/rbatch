require 'logger'
require 'pathname'

module RBatch
  class Log
    @@verbose = false
    @@def_opt = {
      :file_prefix => "%Y%m%d_%H%M%S_",
      :file_suffix => ".log",
      :output_dir  => File.join(File.dirname(RBatch.program_name), ".." , "log"),
      :path        => nil,
      :formatter   => nil,
      :level       => Logger::INFO
    }

    @opt

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
      # parse option
      @opt = @@def_opt.clone
      @@def_opt.each_key do |key|
        if opt != nil  && opt[key]
          @opt[key] = opt[key]
        elsif RBatch.common_config != nil && RBatch.common_config["log"] && RBatch.common_config["log"][key.to_s]
          @opt[key] = RBatch.common_config[:log][key]
        end
      end
      # determine log file name
      if @opt[:path].nil?
        file = Time.now.strftime(@opt[:file_prefix]) + Pathname(File.basename(RBatch.program_name)).sub_ext(@opt[:file_suffix]).to_s
        path = File.join(@opt[:output_dir],file)
      else
        path = @opt[:path]
      end
      # create Logger instance
      puts "Logfile Path = " + path if @@verbose
      puts "RBatch.program_name = " + RBatch.program_name if @@verbose
      log = Logger.new(path)
      begin
        log.formatter = @opt[:formatter] if @opt[:formatter]
        log.level = @opt[:level]
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

