require 'fileutils'
require 'tempfile'
require 'tmpdir'
require 'timeout'
module RBatch

  class Cmd
    @cmd_str
    @opt
    @vars
    def initialize(vars,cmd_str,opt = nil)
      raise(Cmd::Exception,"Command string is nil") if cmd_str.nil?
      @cmd_str = cmd_str
      @vars = vars.clone
      if ! opt.nil?
        # change opt key from "hoge" to "log_hoge"
        tmp = {}
        opt.each_key do |key|
          tmp[("cmd_" + key.to_s).to_sym] = opt[key]
        end
        @vars.merge!(tmp)
      end
    end

    def run()
      stdout_file = Tempfile::new("rbatch_tmpout",Dir.tmpdir)
      stderr_file = Tempfile::new("rbatch_tmperr",Dir.tmpdir)
      pid = spawn(@cmd_str,:out => [stdout_file,"w"],:err => [stderr_file,"w"])
      status = nil
      if @vars[:cmd_timeout] != 0
        begin
          timeout(@vars[:cmd_timeout]) do
            status =  Process.waitpid2(pid)[1] >> 8
          end
        rescue Timeout::Error => e
          begin
            Process.kill('SIGINT', pid)
            raise(Cmd::Exception,"Run time of command \"#{@cmd_str}\" is over #{@vars[:cmd_timeout].to_s} sec. Success to kill process : PID=#{pid}" )
          rescue
            raise(Cmd::Exception,"Run time of command \"#{@cmd_str}\" is over #{@vars[:cmd_timeout].to_s} sec. Fail to kill process : PID=#{pid}" )
          end
        end
      else
        status =  Process.waitpid2(pid)[1] >> 8
      end
      result = RBatch::CmdResult.new(stdout_file,stderr_file,status,@cmd_str)
      if @vars[:cmd_raise] && status != 0
        raise(Cmd::Exception,"Command exit status is not 0. result: " + result.to_s)
      end
      return result
    end
  end

  class CmdResult
    @stdout_file
    @stderr_file
    @status
    @cmd_str
    def initialize(stdout_file, stderr_file, status, cmd_str)
      @stdout_file = stdout_file
      @stderr_file = stderr_file
      @status = status
      @cmd_str = cmd_str
    end
    def stdout_file ; @stdout_file ; end
    def stderr_file ; @stderr_file ; end
    def status      ; @status      ; end
    def cmd_str     ; @cmd_str     ; end
    def stdout
      File.read(@stdout_file)
    end
    def stderr
      File.read(@stderr_file)
    end
    def to_h
      {:cmd_str => @cmd_str,:stdout => stdout, :stderr => stderr, :status => status}
    end
    def to_s
      to_h.to_s
    end
  end

  class RBatch::Cmd::Exception < Exception ; end

end
