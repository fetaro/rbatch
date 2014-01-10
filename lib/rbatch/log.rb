require 'logger'
require 'fileutils'
require 'pathname'
require 'net/smtp'

module RBatch
  class Log
    @@log_level_map = {
      "debug" => Logger::DEBUG,
      "info"  => Logger::INFO,
      "warn"  => Logger::WARN,
      "error" => Logger::ERROR,
      "fatal" => Logger::FATAL
    }
    attr :name,:path,:opt,:log,:stdout_log

    # Logging Block.
    # 
    # ==== Params
    # +opt+ = Option hash object.
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
      @name = @opt[:log_name].clone
      @name.gsub!("<date>", Time.now.strftime("%Y%m%d"))
      @name.gsub!("<time>", Time.now.strftime("%H%M%S"))
      @name.gsub!("<prog>", RBatch.ctrl.program_base)
      @name.gsub!("<host>", RBatch.ctrl.host_name)
      @log_dir = @opt[:log_dir].gsub("<home>",RBatch.ctrl.home_dir)
      @path = File.join(@log_dir,@name)
      # create Logger instance
      begin
        if @opt[:log_append] && File.exist?(@path)
          @log = Logger.new(open(@path,"a"))
        else
          @log = Logger.new(open(@path,"w"))
        end
      rescue Errno::ENOENT => e
        raise 
        RBatch.ctrl.journal 1, "Can not open log file  - #{@path}"
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
        @stdout_log.formatter = proc do |severity, datetime, progname, msg|
        head = "[" + sprintf("%-5s",severity) +"]"
        if msg.is_a? Exception
          "#{head} #{msg}\n" + msg.backtrace.map{|s| "    [backtrace] #{s}"}.join("\n") + "\n"
        else
          "#{head} #{msg}\n"
        end
      end

      end
      # delete old log
      self.delete_old_log(@opt[:log_delete_old_log_date]) if @opt[:log_delete_old_log]
      # add self to RBatch Controller
      RBatch.ctrl.add_log(self)
      RBatch.ctrl.journal 1, "Start Logging: \"#{@path}\""
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

    def journal(a)
      @log.info(a)
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
                         + @opt[:log_name].gsub("<prog>",RBatch.ctrl.program_base)\
                           .gsub("<time>","[0-2][0-9][0-5][0-9][0-5][0-9]")\
                           .gsub("<date>","([0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9])")\
                         + "$")
          if r =~ file && Date.strptime($1,"%Y%m%d") <= Date.today - date
            RBatch.ctrl.journal 1, "Delete old log file: " + File.join(@log_dir , file)
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
Subject: [RBatch] #{RBatch.ctrl.program_name} has error
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

