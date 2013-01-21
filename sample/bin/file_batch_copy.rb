# -*- coding: utf-8 -*-
require 'rbatch'
require 'fileutils'

# ファイル一括コピー
RBatch::Log.new do |log|
  target_dir = RBatch::config["target_dir"]
  RBatch::config["file_list"].each do | file |
    log.info("copy " + file + " -> " + target_dir)
    FileUtils.cp_r(file,target_dir)
  end
end

