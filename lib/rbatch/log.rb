require 'logger'
require 'fileutils'
require 'pathname'
require 'net/smtp'


module RBatch
  class Log
    @@FORMATTER = proc do |severity, datetime, progname, msg|
      head = "[#{datetime}] [" + sprintf("%-5s",severity) +"]"
      if msg.is_a? Exception
        "#{head} #{msg}\n" + msg.backtrace.map{|s| "    [backtrace] #{s}"}.join("\n") + "\n"
      else
        "#{head} #{msg}\n"
      end
    end
    @@STDOUT_FORMATTER = proc do |severity, datetime, progname, msg|
      head = "[" + sprintf("%-5s",severity) +"]"
      if msg.is_a? Exception
        "#{head} #{msg}\n" + msg.backtrace.map{|s| "    [backtrace] #{s}"}.join("\n") + "\n"
      else
        "#{head} #{msg}\n"
      end
    end
    @@LOG_LEVEL_MAP = {
      "debug" => Logger::DEBUG,
      "info"  => Logger::INFO,
      "warn"  => Logger::WARN,
      "error" => Logger::ERROR,
      "fatal" => Logger::FATAL
    }
    @@def_vars
    # @param [RBatch::Variables] v
    def Log.def_vars=(v)
      raise ArgumentError, "type mismatch: #{v} for #RBatch::Variables" if ! a.kind_of?(RBatch::Variables)
      @@def_vars=v
    end
    # @return [RBatch::Variables]
    def Log.def_vars    ; @@def_vars ; end
    @@journal
    # @param [RBatch::Journal] j
    def Log.journal=(j) ; @@journal=j ; end

    @vars
    @opt
    @log
    @stdout_log

    # External command wrapper
    # @option opt [String] :log_dir
    # @option opt [String] :log_name
    # @option opt [Boolean] :log_append
    # @option opt [String] :log_level
    # @option opt [Boolean] :log_stdout
    # @option opt [Boolean] :log_delete_old_log
    # @option opt [Integer] :log_delete_old_log_date
    # @option opt [Boolean] :log_send_mail
    # @option opt [String] :log_mail_to
    # @option opt [String] :log_mail_from
    # @option opt [String] :log_mail_server_host
    # @option opt [Integer] :log_mail_server_port
    # @raise [RBatch::LogException]
    # @yield [log] RBatch::Log instance
    # @return [RBatch::Log]
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
      self.delete_old_log(@vars[:log_delete_old_log_date]) if @vars[:log_delete_old_log]
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
            self.fatal(e)
            self.fatal("Caught SystemExit. RBatch Exit with status " + e.status.to_s)
            exit e.status
          end
        rescue Exception => e
          self.fatal(e)
          self.fatal("Caught exception. RBatch Exit with status 1")
          exit 1
        ensure
          self.close
        end
      end
    end

    def fatal(a)
      @stdout_log.fatal(a) if @vars[:log_stdout]
      @log.fatal(a)
      send_mail(a) if @vars[:log_send_mail]
    end

    def error(a)
      @stdout_log.error(a) if @vars[:log_stdout]
      @log.error(a)
      send_mail(a) if @vars[:log_send_mail]
    end

    def warn(a)
      @stdout_log.warn(a) if @vars[:log_stdout]
      @log.warn(a)
    end

    def info(a)
      @stdout_log.info(a) if @vars[:log_stdout]
      @log.info(a)
    end

    def debug(a)
      @stdout_log.debug(a) if @vars[:log_stdout]
      @log.debug(a)
    end

    def journal(a)
      @log.info("[RBatch] " + a)
    end

    def close
      @log.close
    end

    # Delete old log files.
    # @param [Integer] date expire days
    def delete_old_log(date = 7)
      if Dir.exists?(@vars[:log_dir]) && @vars.raw_value(:log_name).include?("<date>")
        Dir::foreach(@vars[:log_dir]) do |file|
          r = Regexp.new("^" \
                         + @vars.raw_value(:log_name).gsub("<prog>",@vars[:program_base])\
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

    private

    # send mail
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

