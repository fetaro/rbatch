# -*- coding: utf-8 -*-
# Copyright:: Copyright(C) 2011, Nomura Research Institute, Ltd.
# $Id: retry_spec.rb 528 2011-07-28 08:28:51Z lki-w-yanmiao $
#
# リトライ機能モジュールをテストするSpecファイル

require 'iax/retry'
require File.dirname(__FILE__) + '/common/validator'

describe 'retry' do
  before(:all) do
    @count = 3
    @interval = 10

    @validator = Validator.new
    @log_file = @validator.init_log
    File.open(@log_file, "w") {}
  end

  after(:each) do
    File.open(@log_file, "w") {}
  end

  describe 'インタフェース' do
    describe 'パラメータ' do
      describe 'count' do
        it "は正常値の場合、正常に終了する" do
          IAX.retry(@count, @interval) {"test678"}

          # ログメッセージチェック
          # 「エラーが発生しました、エラー詳細:」というメッセージが存在しない
          error_report = @validator.log_validate("エラーが発生しました、エラー詳細:")
          error_report.should_not be_nil
        end
      end

      describe 'interval' do
        it "はintervalを指定しない場合、ブロックに発生した異常をスローする。" do
          # 期待結果をチェック
          # IAX::RuntimeError例外をスローする。
          proc{IAX.retry(@count) {raise RuntimeError}}.should raise_error RuntimeError

          # ログメッセージチェック
          error_report = @validator.log_validate("エラーが発生しました、エラー詳細:",
            "リトライします(1/3)。",
            "エラーが発生しました、エラー詳細:",
            "リトライします(2/3)。",
            "エラーが発生しました、エラー詳細:",
            "リトライします(3/3)。",
            "エラーが発生しました、エラー詳細:",
            "リトライ回数オーバー、総回数:3、リトライ間隔:0秒。")
          error_report.should be_nil
        end
      end
    end
  end

  describe 'ホワイトボックステスト' do
    describe 'retry' do
      it 'は、ブロックが指定しない場合、エラーとする。' do
        proc{IAX.retry(3, 1)}.should raise_error LocalJumpError
      end

      it 'は、ブロック実行で例外が発生した場合、リトライ前に interval 秒をスリープする' do
        proc do
          IAX.retry(3, 1) do
            raise "error occurred!"
          end
        end.should raise_error RuntimeError, "error occurred!"

        # ログメッセージチェック
        error_report = @validator.log_validate("エラーが発生しました、エラー詳細:",
          "リトライします(1/3)。",
          "エラーが発生しました、エラー詳細:",
          "リトライします(2/3)。",
          "エラーが発生しました、エラー詳細:",
          "リトライします(3/3)。",
          "エラーが発生しました、エラー詳細:",
          "リトライ回数オーバー、総回数:3、リトライ間隔:1秒。")
        error_report.should be_nil
      end

      it 'ブロック実行で例外が発生した場合、リトライを行わない' do
        proc do
          IAX.retry(0, 1) do
            raise "error occurred!"
          end
        end.should raise_error RuntimeError, "error occurred!"

        # ログメッセージチェック
        # 「実行失敗。リトライします」というメッセージが存在しない
        error_report = @validator.log_validate("リトライします")
        error_report.should_not be_nil
      end
    end
  end
end
