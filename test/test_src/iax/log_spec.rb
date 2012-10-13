# -*- coding: utf-8 -*-
# Copyright:: Copyright(C) 2011, Nomura Research Institute, Ltd.
# $Id: log_spec.rb 482 2011-06-14 10:20:23Z lki-w-yanmiao $
# Author:: LKI 朱

require 'iax/log'
require 'fileutils'
require File.dirname(__FILE__) + '/common/validator'

describe 'IAX::Log' do
  before(:all) do
    @validator = Validator.new
    @log_file = @validator.init_log
  end
  
  before(:each) do
    file = File.open(@log_file, "w")
    file.close
  end

  after(:all) do
    file = File.open(@log_file, "w")
    file.close
  end
  
  describe 'exception' do
    describe 'パラメータ' do
      describe 'e' do
        it 'は付加メッセージを指定した場合、出力したログに付加メッセージを含めている' do
          e = ArgumentError.new
          IAX.log.exception(e, "付加メッセージ")

          # ログメッセージチェック
          error_report = @validator.log_validate("ERROR 付加メッセージ")
          error_report.should be_nil
        end
      end

      describe 'additional_message' do
        it 'は付加メッセージを指定しない場合、ログが正常出力できる' do
          e = ArgumentError.new("test")
          IAX.log.exception(e)

          # ログメッセージチェック
          error_report = @validator.log_validate("test")
          error_report.should be_nil
        end
      end
    end
  end
end
