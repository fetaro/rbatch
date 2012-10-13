# -*- coding: utf-8 -*-
# Copyright:: Copyright(C) 2011, Nomura Research Institute, Ltd.
# $Id: default_record_formatter_spec.rb 526 2011-07-28 07:52:42Z lki-w-yanmiao $
#
# デフォルトレコードフォーマットクラスをテストするSpecファイル
require 'kconv'
require 'date'
require 'iax/log'

describe 'format_exception' do
  before(:all) do
    @recordformatter = IAX::Log::Versatile::RecordFormatter.new
    @lv = IAX::Log::Lv::ERROR
    @e = ArgumentError.new("テストエラー発生")
    @computername = ""
    case RUBY_PLATFORM
      when /mswin|mingw/
        @computername = ENV['COMPUTERNAME']
      when /cygwin/
        @computername = ENV['COMPUTERNAME']
      when /linux/
        @computername = ENV['HOSTNAME']
    end
    @additional_message = "付加メッセージ"
  end

  describe 'インタフェース' do
    describe 'パラメータ入力' do
      describe 'additional_message' do
        it "はadditional_messageは存在する場合、正常に終了する" do
          # 期待結果、以下のレコードを戻りる
          record_expect_last = "0: (ArgumentError) テストエラー発生"
          return_record = @recordformatter.format_exception(@lv, @e, @additional_message)

          #レコードを確認する
          return_record.toutf8.scan(
            /#{@computername} \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} \[ ERROR \] #{@additional_message}/)
            .empty?.should be_false
          return_record.toutf8.include?(record_expect_last).should be_true
        end

        it "additional_messageは存在しない場合、正常に終了する" do
          @additional_message = nil
          # 期待結果、以下のレコードを戻りる
          record_expect_last = "(ArgumentError) テストエラー発生"
          return_record = @recordformatter.format_exception(@lv, @e, @additional_message)

          #レコードを確認する
          return_record.toutf8.scan(
            /#{@computername} \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} \[ ERROR \]/)
            .empty?.should be_false
          return_record.toutf8.include?(record_expect_last).should be_true
        end
      end
    end
  end
end
