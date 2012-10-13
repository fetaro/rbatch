# -*- coding: utf-8 -*-
# Copyright:: Copyright(C) 2009, Nomura Research Institute, Ltd.
# $Id: validator.rb 682 2012-04-20 10:20:18Z t9-watanabe $
# Author:: LKI朱

require 'date'
require 'kconv'
require 'fileutils'

class Validator

  def init_log

    default_dir = File.join(File.dirname(__FILE__), '/../../../../log')
    FileUtils.mkdir_p(default_dir)
    default_date = DateTime.now.strftime("%Y%m%d")
    default_file = "#{default_date}_rspec.log"
    @file_name = File.join(default_dir, default_file)

    IAX::Log.set_option(:appender, :file_name, default_file)
    IAX::Log.set_option(:appender, :dir_name, default_dir)
    IAX::CMD.set_option(:tmp_dir, default_dir)

    return @file_name
  end

  def log_validate(*msg)
    begin
      log = open(@file_name, 'r')
      count = 0
      while !log.eof? && !msg[count].nil?
        line = log.readline.toutf8
        lev = msg[count].split(' ')[0]
        mes = msg[count].sub(/#{lev}/, '')

        count += 1 if line.include?(lev.strip) && line.include?(mes.strip)
      end
      raise msg[count] unless count == msg.length
      return nil
    rescue => e
      return e.message
    ensure
      log.close if log 
    end 
  end

  def senju_log_validate(dir_name, msg)
    senju_log_name = ""
    Dir.entries(dir_name).each do |file_name|
      if file_name =~ /^sjLOG_sjANM_sendmsg_/
        senju_log_name = file_name
      end
    end
    begin
      log = open(File.join(dir_name, senju_log_name), 'r')
      found = 0
      while !log.eof?
        line = log.readline.sub(/\n$/,'').toutf8.split(",")
        msg.length.times do |count|
          found += 1 if line.include?(msg[count -1])
        end
      end
      raise msg[found] unless found == msg.length
      return nil
    rescue => e
      return e.message
    ensure
      log.close if log
    end
  end
end # end of Validator
