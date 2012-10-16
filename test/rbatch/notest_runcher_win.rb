# -*- coding: utf-8 -*-
# Copyright:: Copyright(C) 2011, Nomura Research Institute, Ltd.
# $Id: windows_cmd_spec.rb 528 2011-07-28 08:28:51Z lki-w-yanmiao $
# Author:: LKI 朱

require 'kconv'
require 'iax/cmd'
require 'iax/log'
require File.dirname(__FILE__) + '/common/validator'

describe 'IAX/windows_cmd' do
  before(:all) do
    @validator = Validator.new
    @log_file = @validator.init_log
    @path_env = ENV["Path"]
    command_path = File.dirname(__FILE__) + "/../../mocks/"
    ENV["Path"] = "#{command_path};" + @path_env
  end
  
  after(:all) do
    file = File.open(@log_file, "w")
    file.close
    ENV["Path"] = @path_env
  end

  after(:each) do
    IAX.cmd_journal_out=false
  end

  before(:each) do
    IAX.cmd_journal_out=false
    file = File.open(@log_file, "w")
    file.close
  end

  describe 'コマンド実行(cmd)' do
    describe 'パラメータ' do
      describe '*cmd_params' do
        it 'はコマンドの戻りエラーレベルはより256大きい、正常終了する' do
          # コマンド実行
          cmd_params = ["win_cmd"]
          cmd_params << "257"
          stdout, stderr, status = IAX.cmd(*cmd_params)

          # 期待結果チェック
          # stdout結果チェック
          stdout.toutf8.should == "stdout:\nあい\nうえお\n....."

          # stdout結果チェック
          stderr.toutf8.should ==  "stderr:\nかき\nくけこ"

          # stdout結果チェック
          status.should == 257
        end

        it 'はコマンドの戻りエラーレベルより256は小さい、正常終了する' do
          # コマンド実行
          cmd_params = ["win_cmd"]
          cmd_params << "50"
          stdout, stderr, status = IAX.cmd(*cmd_params)

          # 期待結果チェック
          # stdout結果チェック
          stdout.toutf8.should == "stdout:\nあい\nうえお\n....."

          # stdout結果チェック
          stderr.toutf8.should ==  "stderr:\nかき\nくけこ"

          # stdout結果チェック
          status.should == 50
        end
      end
    end

    describe '非パラメータ入力' do
      describe '@cmd_journal_out' do
        it 'は非ブロックで使う、コマンドの戻りエラーレベルより256は大きい、ログ出力するように、正常に完了' do
          IAX.cmd_journal_out=true
          
          # 履歴ログ出力チェック
          IAX.cmd_journal_out.should be_true
          # コマンド実行
          cmd_params = ["win_cmd"]
          cmd_params << "257"
          stdout, stderr, status = IAX.cmd(*cmd_params)

          # 期待結果チェック
          # stdout結果チェック
          stdout.toutf8.should == "stdout:\nあい\nうえお\n....."

          # stdout結果チェック
          stderr.toutf8.should ==  "stderr:\nかき\nくけこ"

          # stdout結果チェック
          status.should == 257

          # ログメッセージチェック
          error_report = @validator.log_validate("実行結果:ステータス「257」")
          error_report.should be_nil
        end

        it 'はブロックで使う、コマンドの戻りエラーレベルより256は大きい、ログ出力しないように、正常に完了' do
          # コマンド実行
          cmd_params = ["win_cmd"]
          cmd_params << "257"
          IAX.cmd(*cmd_params) do |stdout_io, stderr_io, status|
            # 期待結果チェック
            stdout_io.read().toutf8.should == "stdout:\nあい\nうえお\n....."
            stderr_io.read().toutf8.should == "stderr:\nかき\nくけこ"
            status.should == 257
          end
        end

        it 'は非ブロックで使う、コマンドの戻りエラーレベルより256は小さい、ログ出力するように、正常に完了' do
          IAX.cmd_journal_out=true

          # 履歴ログ出力チェック
          IAX.cmd_journal_out.should be_true
          # コマンド実行
          cmd_params = ["win_cmd"]
          cmd_params << "50"
          stdout, stderr, status = IAX.cmd(*cmd_params)

          # 期待結果チェック
          # stdout結果チェック
          stdout.toutf8.should == "stdout:\nあい\nうえお\n....."

          # stdout結果チェック
          stderr.toutf8.should ==  "stderr:\nかき\nくけこ"

          # stdout結果チェック
          status.should == 50

          # ログメッセージチェック
          error_report = @validator.log_validate("実行結果:ステータス「50」")
          error_report.should be_nil
        end

        it 'はブロックで使う、コマンドの戻りエラーレベルより256は小さい、ログ出力しないように、正常に完了' do
          # コマンド実行
          cmd_params = ["win_cmd"]
          cmd_params << "50"
          IAX.cmd(*cmd_params) do |stdout_io, stderr_io, status|
            # 期待結果チェック
            stdout_io.read().toutf8.should == "stdout:\nあい\nうえお\n....."
            stderr_io.read().toutf8.should == "stderr:\nかき\nくけこ"
            status.should == 50
          end
        end
      end
    end
  end
end