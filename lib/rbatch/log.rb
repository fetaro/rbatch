require 'logger'
require 'fileutils'
require 'pathname'
require 'net/smtp'


module RBatch
  class Log
    # @private
    @@FORMATTER = proc do |severity, datetime, progname, msg|
      head = "[#{datetime}] [" + sprintf("%-5s",severity) +"]"
      if msg.is_a? Exception
        "#{head} #{msg}\n" + msg.backtrace.map{|s| "    [backtrace] #{s}"}.join("\n") + "\n"
      else
        "#{head} #{msg}\n"
      end
    end

    # @private
    @@STDOUT_FORMATTER = proc do |severity, datetime, progname, msg|
      head = "[" + sprintf("%-5s",severity) +"]"
      if msg.is_a? Exception
        "#{head} #{msg}\n" + msg.backtrace.map{|s| "    [backtrace] #{s}"}.join("\n") + "\n"
      else
        "#{head} #{msg}\n"
      end
    end

    # @private
    @@LOG_LEVEL_MAP = {
      "debug" => Logger::DEBUG,
      "info"  => Logger::INFO,
      "warn"  => Logger::WARN,
      "error" => Logger::ERROR,
      "fatal" => Logger::FATAL
    }

    # @private
    @@def_vars

    # @private
    # @param [RBatch::Variables] v
    def Log.def_vars=(v)
      raise ArgumentError, "type mismatch: #{v} for #RBatch::Variables" if ! v.kind_of?(RBatch::Variables)
      @@def_vars=v
    end

    # @private
    # @return [RBatch::Variables]
    def Log.def_vars    ; @@def_vars ; end

    # @private
    @@journal

    # @private
    # @param [RBatch::Journal] j
    def Log.journal=(j) ; @@journal=j ; end

    # @private
    @vars

    # @private
    @opt

    # @private
    @log

    # @private
    @stdout_log

    # External command wrapper
    # @option opt [String] :dir Output directory
    # @option opt [String] :name 
    #   Log file name.
    #   Default is "<date>_<time>_<prog>.log".
    #   <data> is replaced to YYYYMMDD date string
    #   <time> is replaced to HHMMSS time string
    #   <prog> is replaced to Program file base name (except extention).
    #   <host> is replaced to Hostname.
    # @option opt [Boolean] :append
    # @option opt [String] :level
    #  Effective values are "debug","info","wran","error",and "fatal".
    # @option opt [Boolean] :stdout
    #   Print log string both log file and STDOUT
    # @option opt [Boolean] :delete_old_log
    #   If this is true, delete old log files when this is called.
    #   If log filename does not include "<date>", do nothing.
    # @option opt [Integer] :delete_old_log_date
    # @option opt [Boolean] :send_mail
    #   When log.error(str) is called,
    #   log.fatal(str) is called , or rescue an Exception,
    #   send e-mail.
    # @option opt [String] :mail_to
    # @option opt [String] :mail_from
    # @option opt [String] :mail_server_host
    # @option opt [Integer] :mail_server_port
    # @raise [RBatch::LogException]
    # @yield [log] RBatch::Log instance
    # @return [RBatch::Log]
    # @example
    #  require 'rbatch'
    #  RBatch::Log.new{ |log|
    #    log.info "info string"
    #    log.error "error string"
    #    raise "exception" # => rescued in this block
    #  }
    # @example use option
    #  require 'rbatch'
    #  RBatch::Log.new({:name => "hoge.log"}){ |log|
    #    log.info "info string"
    #  }

    def initialize(opt=nil)
      @opt = opt
      @vars = @@def_vars.clone
      if ! opt.nil?
        # change opt key from "hoge" to "log_hoge"
        tmp = {}
        opt.each_key do |key|
          tmp[("log_" + key.to_s).to_sym] = opt[key]
        end
        @vars.merge!(tmp)
      end
      @path = File.join(@vars[:log_dir],@vars[:log_name])
      unless Dir.exist? @vars[:log_dir]
        raise LogException,"Log directory \"#{@vars[:log_dir]}\" does not exist"
      end
      # create Logger instance
      begin
        if @vars[:log_append] && File.exist?(@path)
          @log = Logger.new(open(@path,"a"))
        else
          @log = Logger.new(open(@path,"w"))
        end
      rescue Errno::ENOENT => e
        raise LogException,"Can not open log file  - #{@path}"
      end
      # set logger option
      @log.level = @@LOG_LEVEL_MAP[@vars[:log_level]]
      @log.formatter = @@FORMATTER
      if @vars[:log_stdout]
        # ccreate Logger instance for STDOUT
        @stdout_log = Logger.new(STDOUT)
        @stdout_log.level = @@LOG_LEVEL_MAP[@vars[:log_level]]
        @stdout_log.formatter = @@STDOUT_FORMATTER
      end
      # delete old log
      delete_old_log(@vars[:log_delete_old_log_date]) if @vars[:log_delete_old_log]
      # Start logging
      @@journal.put 1,"Logging Start: \"#{@path}\""
      @@journal.add_log(self)
      if block_given?
        begin
          yield self
        rescue SystemExit => e
          if e.status == 0
            exit 0
          else
            fatal(e)
            fatal("Caught SystemExit. RBatch Exit with status " + e.status.to_s)
            exit e.status
          end
        rescue Exception => e
          fatal(e)
          fatal("Caught exception. RBatch Exit with status 1")
          exit 1
        ensure
          close
        end
      end
    end

    # Out put log with ERROR level
    # @param [String] str log string
    def fatal(str)
      @stdout_log.fatal(str) if @vars[:log_stdout]
      @log.fatal(str)
      send_mail(str) if @vars[:log_send_mail]
    end

    # Out put log with ERROR level
    # @param [String] str log string
    def error(str)
      @stdout_log.error(str) if @vars[:log_stdout]
      @log.error(str)
      send_mail(str) if @vars[:log_send_mail]
    end

    # Out put log with WARN level
    # @param [String] str log string
    def warn(str)
      @stdout_log.warn(str) if @vars[:log_stdout]
      @log.warn(str)
    end

    # Out put log with INFO level
    # @param [String] str log string
    def info(str)
      @stdout_log.info(str) if @vars[:log_stdout]
      @log.info(str)
    end

    # Out put log with DEBUG level
    # @param [String] str log string
    def debug(str)
      @stdout_log.debug(str) if @vars[:log_stdout]
      @log.debug(str)
    end

    # @private
    def journal(str)
      @log.info("[RBatch] " + str)
    end

    private
    def delete_old_log(date = 7)
      if Dir.exists?(@vars[:log_dir]) && @vars.raw_value(:log_name).include?("<date>")
        Dir::foreach(@vars[:log_dir]) do |file|
          r = Regexp.new("^" \
                         + @vars.raw_value(:log_name).gsub("<prog>",@vars[:program_noext])\
                           .gsub("<time>","[0-2][0-9][0-5][0-9][0-5][0-9]")\
                           .gsub("<date>","([0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9])")\
                         + "$")
          if r =~ file && Date.strptime($1,"%Y%m%d") <= Date.today - date
            @@journal.put 1, "Delete old log file: " + File.join(@vars[:log_dir] , file)
            File::delete(File.join(@vars[:log_dir]  , file))
          end
        end
      end
    end

    def close
      @log.close
    end

    def send_mail(msg)
      body = <<EOT
From: <#{@vars[:log_mail_from]}>
To: <#{@vars[:log_mail_to]}>
Subject: [RBatch] #{@vars[:program_name]} has error
Date: #{Time::now.strftime("%a, %d %b %Y %X %z")}
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

#{msg}
EOT
      Net::SMTP.start(@vars[:log_mail_server_host],@vars[:log_mail_server_port] ) {|smtp|
        smtp.send_mail(body,@vars[:log_mail_from],@vars[:log_mail_to])
      }
    end
  end # end class
  class LogException < StandardError ; end
end # end module

