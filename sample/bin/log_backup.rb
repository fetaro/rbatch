# -*- coding: utf-8 -*-
require 'rbatch'
require 'fileutils'
require 'date'

RBatch::Log.new do |log|
  log.info("Start---------------")
  target_dir = RBatch::config["target_dir"]
  RBatch::config["file_list"].each do |file_wildcard|
    Dir::glob(file_wildcard).each do |file|
      if ! File.exists?(File.join(target_dir,File.basename(file)))
        log.info("Copy " + file + " to " + target_dir)
        FileUtils.cp(file,target_dir)
      else
        log.info("Skip " + file + " (already backuped)")
      end
    end
  end
end

