# -*- coding: utf-8 -*-
# Copyright:: Copyright(C) 2011, Nomura Research Institute, Ltd.
# $Id: cmd_spec.rb 682 2012-04-20 10:20:18Z t9-watanabe $
# Author:: LKI 朱

require 'iax/cmd'
require 'fileutils'
require File.dirname(__FILE__) + '/common/validator'

describe 'IAX' do
  before(:all) do
    @validator = Validator.new
    @log_file = @validator.init_log
  end

  after(:all) do
    file = File.open(@log_file, "w")
    file.close
  end
  
  after(:each) do
    IAX.cmd_journal_out=false
  end
  
  before(:each) do
    IAX.cmd_journal_out=false
    file = File.open(@log_file, "w")
    file.close
  end
  
  describe 'set_option/option' do
    it ':journal_out' do
      IAX::CMD.set_option(:journal_out, true)
      IAX::CMD.option(:journal_out).should == true
      IAX::CMD.set_option(:journal_out, false)
      IAX::CMD.option(:journal_out).should == false
    end
    it ':tmp_dir' do
      bak = IAX::CMD.option(:tmp_dir)
      IAX::CMD.set_option(:tmp_dir, "hoge")
      IAX::CMD.option(:tmp_dir).should == "hoge"
      IAX::CMD.set_option(:tmp_dir, bak)
      IAX::CMD.option(:tmp_dir).should == bak
    end
    it 'Invalid key' do
      bak = IAX::CMD.option(:tmp_dir)
      IAX::CMD.option(:not_exist).should == nil
      proc{
        IAX::CMD.set_option(:not_exist, true)
      }.should raise_error
      IAX::CMD.set_option(:tmp_dir, bak)
      IAX::CMD.option(:tmp_dir).should == bak
    end
  end

  describe 'cmd' do
    describe '*cmd_params' do
      it 'コマンドが存在する' do
        str = "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 0;'"
        stdout, stderr, status = IAX.cmd(str)
        stdout.chomp.should == "1"
        stderr.chomp.should == "2"
        status.should == 0
      end
      it 'コマンドが存在しない' do
        proc{
          stdout, stderr, status = IAX.cmd("not_exist_command")
        }.should raise_error(Errno::ENOENT)
      end
      it 'コマンド正常終了 標準出力65536Byte以上' do
        str = "ruby -e '100000.times{print 0}'"
        stdout, stderr, status = IAX.cmd(str)
        stdout.chomp.size.should == 100000
        status.should == 0
      end
      it 'コマンド異常終了 標準出力65536Byte以上' do
        str = "ruby -e '100000.times{print 0}; exit 1'"
        stdout, stderr, status = IAX.cmd(str)
        stdout.chomp.size.should == 100000
        status.should == 1
      end
      it 'status=1' do
        str = "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'"
        stdout, stderr, status = IAX.cmd(str)
        stdout.chomp.should == "1"
        stderr.chomp.should == "2"
        status.should == 1
      end
      it 'status 256以上(Linuxならばmod256になるのでNG)' do
        str = "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 300;'"
        stdout, stderr, status = IAX.cmd(str)
        stdout.chomp.should == "1"
        stderr.chomp.should == "2"
        # TODO: Linux/Cygwin
        status.should == 300
      end
    end
    describe '@@journal_out' do
      it 'true' do
        IAX::CMD.set_option(:journal_out, true)
        str = "ruby -e 'STDOUT.print so1; STDERR.print se2; exit 3;'"
        IAX.cmd(str)
        @validator.log_validate("so1","se2","3") == true        
      end
    end
    describe '@@tmp_dir' do
      it 'nil' do
        bak = IAX::CMD.option(:tmp_dir)
        IAX::CMD.set_option(:tmp_dir, nil)
        proc{
          IAX.cmd("echo hoge")
        }.should raise_error(IAX::CMD::RuntimeError)
        IAX::CMD.set_option(:tmp_dir, bak)
        IAX::CMD.option(:tmp_dir).should == bak
      end
      it '存在しないディレクトリ' do
	bak = IAX::CMD.option(:tmp_dir)
        IAX::CMD.set_option(:tmp_dir, "notexist")
        proc{
          IAX.cmd("echo hoge")
        }.should raise_error(IAX::CMD::RuntimeError)
        IAX::CMD.set_option(:tmp_dir, bak)
        IAX::CMD.option(:tmp_dir).should == bak
      end
    end
  end

  describe 'cmd_e' do
    describe '*cmd_params' do
      it 'status 0' do
        str = "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 0;'"
        stdout, stderr, status = IAX.cmd_e(str)
        stdout.chomp.should == "1"
        stderr.chomp.should == "2"
        status.should == 0
      end
      it 'status 1' do
        str = "ruby -e 'STDOUT.print 1; STDERR.print 2; exit 1;'"
        proc{
          stdout, stderr, status = IAX.cmd_e(str)
        }.should raise_error
      end
    end
  end

end
