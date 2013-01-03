require 'logger'
require 'pathname'

module RBatch
  #=== About RBatch::Log
  #
  #Use Auto Logging block, RBatch automatically write to logfile.
  #
  #Log file default location is "../log/YYYYMMDD_HHMMSS_${PROG_NAME}.log" .
  #
  #If exception occuerd, then RBatch write stack trace to logfile.
  #
  #=== Sample
  #
  #script : ./bin/sample1.rb
  #
  # require 'rbatch'
  # 
  # RBatch::Log.new(){ |log|  # Logging block
  #   log.info "info string"
  #   log.error "error string"
  #   raise "exception"
  # }
  #
  #
  #logfile : ./log/20121020_005953_sample1.log
  #
  # # Logfile created on 2012-10-20 00:59:53 +0900 by logger.rb/25413
  # I, [2012-10-20T00:59:53.895528 #3208]  INFO -- : info string
  # E, [2012-10-20T00:59:53.895582 #3208] ERROR -- : error string
  # F, [2012-10-20T00:59:53.895629 #3208] FATAL -- : Caught exception; existing 1
  # F, [2012-10-20T00:59:53.895667 #3208] FATAL -- : exception (RuntimeError)
  # test.rb:6:in `block in <main>'
  # /usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in `initialize'
  # test.rb:3:in `new'
  # test.rb:3:in `<main>'
  #
  class Log
    @@verbose = false
    @@def_opt = {
      :name      => "<date>_<time>_<prog>.log",
      :dir       => File.join(File.dirname(RBatch.program_name), ".." , "log"),
      :formatter => nil,
      :append    => true,
      :level     => "info",
      :stdout    => false,
      :quiet     => false
    }
    @@log_level_map = {
      "debug" => Logger::DEBUG,
      "info"  => Logger::INFO,
      "warn"  => Logger::WARN,
      "error" => Logger::ERROR,
      "fatal" => Logger::FATAL
    }

    @opt # option
    @log # log instance for file
    @stdout_log # log instance for STDOUT

    # Set verbose mode flag.
    def Log.verbose=(bol); @@verbose = bol ; end

    # Get verbose mode flag.
    def Log.verbose ; @@verbose ; end

    # Get Option
    def opt; @opt ; end

    # Auto Logging Block.
    # 
    # ==== Params
    # +opt+ = Option hash object. Hash keys is follows.
    # - +:name+ (String) = log file name. Default is "<date>_<time>_<prog>.log"
    # - +:dir+ (String) = log direcotry path. Default is "../log"
    # - +:level+ (String) = log level. ["debug"|"info"|"warn"|"error"|"fatal"] . Default is "info".
    # - +:append+ (Boolean) = appned to log or not(=overwrite). Default is ture.
    # - +:formatter+ (Logger#formatter) = log formatter. instance of Logger#formatter
    # - +:stdout+ (Boolean) = print string both logfile and STDOUT. Default is false.
    # - +:quiet+ (Boolean) = run quiet mode. print STDOUT nothing.  Default is true.
    # ==== Block params
    # +log+ = Instance of +Logger+
    # ==== Sample
    #  RBatch::Log.new({:dir => "/tmp", :level => "info"}){ |log|
    #    log.info "info string"
    #  }
    #
    def initialize(opt = nil)
      # parse option
      @opt = @@def_opt.clone
      @@def_opt.each_key do |key|
        if opt != nil  && opt[key] != nil
          # use argument
          @opt[key] = opt[key]
        elsif RBatch.common_config != nil \
          && RBatch.common_config["log_" + key.to_s] != nil
          # use config
          @opt[key] = RBatch.common_config["log_" + key.to_s]
        else
          # use default
        end
      end
      puts "option = " + @opt.to_s if @@verbose
      # determine log file name
      file = @opt[:name]
      file.gsub!("<date>", Time.now.strftime("%Y%m%d"))
      file.gsub!("<time>", Time.now.strftime("%H%M%S"))
      file.gsub!("<prog>", Pathname(File.basename(RBatch.program_name)).sub_ext("").to_s)
      path = File.join(@opt[:dir],file)
      # create Logger instance
      begin
        if @opt[:append] && File.exist?(path)
          @log = Logger.new(open(path,"a"))
        else
          @log = Logger.new(open(path,"w"))
        end
      rescue Errno::ENOENT => e
        STDERR.puts "RBatch ERROR: Can not open log file  - #{path}" if ! @opt[:quiet]
        raise e
      end
      # set logger option
      @log.formatter = @opt[:formatter] if @opt[:formatter]
      @log.level = @@log_level_map[@opt[:level]]
      if @opt[:stdout]
        # ccreate Logger instance for STDOUT
        @stdout_log = Logger.new(STDOUT)
        @stdout_log.formatter = @opt[:formatter] if @opt[:formatter]
        @stdout_log.level = @@log_level_map[@opt[:level]]
      end
      puts "Log file: " + path if ! @opt[:quiet]
      if block_given?
        begin
          yield self
        rescue => e
          self.fatal("Caught exception; existing 1")
          self.fatal(e)
          exit 1
        ensure
          self.close
        end
      end
    end

    def fatal(a)
      @stdout_log.fatal(a) if @opt[:stdout]
      @log.fatal(a)
    end

    def error(a)
      @stdout_log.error(a) if @opt[:stdout]
      @log.error(a)
    end

    def warn(a)
      @stdout_log.warn(a) if @opt[:stdout]
      @log.warn(a)
    end

    def info(a)
      @stdout_log.info(a) if @opt[:stdout]
      @log.info(a)
    end

    def debug(a)
      @stdout_log.debug(a) if @opt[:stdout]
      @log.debug(a)
    end

    def close
      @stdout_log.close if @opt[:stdout]
      @log.close
    end

  end # end class
end # end module

