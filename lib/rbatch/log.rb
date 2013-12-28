require 'logger'
require 'fileutils'
require 'pathname'
require 'net/smtp'

module RBatch
  #=== About RBatch::Log
  #
  #By using Logging block, RBatch writes to logfile automatically.
  #
  #The default location of log file is "${RB_HOME}/log/YYYYMMDD_HHMMSS_(program base name).log" .
  #
  #If an exception occuerd, then RBatch writes back trace to logfile.
  #
  #=== Sample
  #
  #script : ${RB_HOME}/bin/sample1.rb
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
  #logfile : ${RB_HOME}/log/20121020_005953_sample1.log
  #
  # [2012-10-20 00:59:53 +900] [INFO ] info string
  # [2012-10-20 00:59:53 +900] [ERROR] error string
  # [2012-10-20 00:59:53 +900] [FATAL] Caught exception; existing 1
  # [2012-10-20 00:59:53 +900] [FATAL] exception (RuntimeError)
  #     [backtrace] test.rb:6:in `block in <main>'
  #     [backtrace] /usr/local/lib/ruby192/lib/ruby/gems/1.9.1/gems/rbatch-1.0.0/lib/rbatch/auto_logger.rb:37:in `initialize'
  #     [backtrace] test.rb:3:in `new'
  #     [backtrace] test.rb:3:in `<main>'
  #
  class Log
    @@verbose = false
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
    @prog_base # program file name base
    @file_name # log file name

    # Set verbose mode flag.
    def Log.verbose=(bol); @@verbose = bol ; end

    # Get verbose mode flag.
    def Log.verbose ; @@verbose ; end

    # Get Option
    def opt; @opt ; end

    # Logging Block.
    # 
    # ==== Params
    # +opt+ = Option hash object.
    # - +:name+ (String) = name of log file. Default is "<date>_<time>_<prog>.log". Reservation-words are "<date>","<time>","<prog>","<host>". "<date>" is replaced YYYYMMDD. "<time>" is replaced HHMMSS. "<prog>" is replaced a base-name of program file.
    # - +:dir+ (String) = log direcotry. Default is "${RB_HOME}/log"
    # - +:level+ (String) = log level. Default is "info". ["debug"|"info"|"warn"|"error"|"fatal"] .
    # - +:append+ (Boolean) = appned to log or not(=overwrite). Default is ture.
    # - +:stdout+ (Boolean) = output both the log file and STDOUT. Default is false.
    # ==== Block params
    # +log+ = Instance of +Logger+
    # ==== Sample
    #  RBatch::Log.new({:dir => "/tmp", :level => "info"}){ |log|
    #    log.info "info string"
    #  }
    #
    def initialize(opt = nil)
      # parse option
      tmp = {}
      if opt.nil?
        @opt=RBatch.run_conf.clone
      else
        opt.each_key do |key|
          tmp[("log_" + key.to_s).to_sym] = opt[key]
        end
        @opt=RBatch.run_conf.merge(tmp)
      end

      # determine log file name
      @prog_base = Pathname(File.basename(RBatch.program_name)).sub_ext("").to_s
      @file_name = @opt[:log_name].clone
      @file_name.gsub!("<date>", Time.now.strftime("%Y%m%d"))
      @file_name.gsub!("<time>", Time.now.strftime("%H%M%S"))
      @file_name.gsub!("<prog>", @prog_base)
      @file_name.gsub!("<host>", @opt[:log_hostname])
      @log_dir = @opt[:log_dir].gsub("<home>",RBatch.home_dir)
      path = File.join(@log_dir,@file_name)
      # create Logger instance
      begin
        if @opt[:log_append] && File.exist?(path)
          @log = Logger.new(open(path,"a"))
        else
          @log = Logger.new(open(path,"w"))
        end
      rescue Errno::ENOENT => e
        RBatch.journal :error, "Can not open log file  - #{path}"
        raise e
      end
      # set logger option
      formatter = proc do |severity, datetime, progname, msg|
        head = "[#{datetime}] [" + sprintf("%-5s",severity) +"]"
        if msg.is_a? Exception
          "#{head} #{msg}\n" + msg.backtrace.map{|s| "    [backtrace] #{s}"}.join("\n") + "\n"
        else
          "#{head} #{msg}\n"
        end
      end
      @log.level = @@log_level_map[@opt[:log_level]]
      @log.formatter = formatter
      if @opt[:log_stdout]
        # ccreate Logger instance for STDOUT
        @stdout_log = Logger.new(STDOUT)
        @stdout_log.level = @@log_level_map[@opt[:log_level]]
        @stdout_log.formatter = formatter
      end
      RBatch.journal :info,"Start Logging. Log file: " + path
      # delete old log
      self.delete_old_log(@opt[:log_delete_old_log_date]) if @opt[:log_delete_old_log]
      # Start logging
      if block_given?
        begin
          yield self
        rescue Exception => e
          self.fatal(e)
          self.fatal("Caught exception. Exit 1")
          exit 1
        ensure
          self.close
        end
      end
    end

    def fatal(a)
      @stdout_log.fatal(a) if @opt[:log_stdout]
      @log.fatal(a)
      send_mail(a) if @opt[:log_send_mail]
    end

    def error(a)
      @stdout_log.error(a) if @opt[:log_stdout]
      @log.error(a)
      send_mail(a) if @opt[:log_send_mail]
    end

    def warn(a)
      @stdout_log.warn(a) if @opt[:log_stdout]
      @log.warn(a)
    end

    def info(a)
      @stdout_log.info(a) if @opt[:log_stdout]
      @log.info(a)
    end

    def debug(a)
      @stdout_log.debug(a) if @opt[:log_stdout]
      @log.debug(a)
    end

    def close
      @stdout_log.close if @opt[:log_stdout]
      @log.close
    end

    # Delete old log files.
    # If @opt[:log_name] is not include "<date>", then do nothing.
    #
    # ==== Params
    # - +date+ (Integer): The day of leaving log files
    #
    def delete_old_log(date = 7)
      if Dir.exists?(@log_dir) && @opt[:log_name].include?("<date>")
        Dir::foreach(@log_dir) do |file|
          r = Regexp.new("^" \
                         + @opt[:log_name].gsub("<prog>",@prog_base)\
                           .gsub("<time>","[0-2][0-9][0-5][0-9][0-5][0-9]")\
                           .gsub("<date>","([0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9])")\
                         + "$")
          if r =~ file && Date.strptime($1,"%Y%m%d") <= Date.today - date
            RBatch.journal :info, "Delete old log file: " + File.join(@log_dir , file)
            File::delete(File.join(@log_dir  , file))
          end
        end
      end
    end

    private

    # send mail
    def send_mail(msg)
      body = <<EOT
From: <#{@opt[:log_mail_from]}>
To: <#{@opt[:log_mail_to]}>
Subject: [RBatch] #{RBatch.program_name} has error
Date: #{Time::now.strftime("%a, %d %b %Y %X %z")}
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

#{msg}
EOT
      Net::SMTP.start(@opt[:log_mail_server_host],@opt[:log_mail_server_port] ) {|smtp|
        smtp.send_mail(body,@opt[:log_mail_from],@opt[:log_mail_to])
      }
    end
  end # end class
end # end module

