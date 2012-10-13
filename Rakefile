#
# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'rbatch'
  s.version = '1.0.0'
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'batch framework'
  s.description = ''
  s.author = 'fetaro'
  s.email = 'fetaro@gmail.com'
  s.homepage = 'https://github.com/fetaro/rbatch'
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'CHANGELOG', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "IAX Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

task :test => %w[spec:spec_test_core]

################################################
# RSpec自動テストの共通関数
################################################
begin
require "rspec/core/rake_task"
rescue LoadError=>e
end
require "fileutils"

def remove_dir(dir)
    FileUtils.remove_dir(dir, {:force => true})
    puts "  [delete  ] #{dir}"
end

################################################
# 一時フォルダとテスト対象を構成する
################################################
def copy_test_code(base_dir_src, dir_list, file_list, base_dir_target)
  i = 0
  dir_list.each do |dir|
    des = base_dir_target + dir

    FileUtils.mkdir_p(des)
    puts "  [make dir] \"#{des}\""

    file_list[i].each do |file|
      src = base_dir_src + dir + file
      FileUtils.cp_r(src, des)
      puts "  [copy    ] From \"#{src}\" To \"#{des}#{file}\""
    end
    i = i + 1
  end
end

namespace :spec do
  ################################################
  # Rspecテストタスク:build_folder_core
  # test_coreのテスト対象を用意する
  #
  # ==== 使用例
  #  test_target = "test/test_src"      ←　テスト一時フォルダを指定する
  #  test_src = "test/cases"            ←　テストコードの元を指定する
  #  dir_list =  ["/iax/common/",       ←　必須
  #               "/iax/"               ←　テスト対象のフォルダを指定する
  #              ]
  #  file_list = [["validator.rb"],     ←　必須（テストの初期化を実施するため）
  #               ["cmd_spec.rb", ...]  ←　dir_list[1]中の各テスト対象(.rb)を指定する
  #              ]
  #  copy_test_code(test_src, dir_list, file_list, test_target)
  ################################################
  task :build_folder_core do
    puts "\n\npreparation start======TEST CORE======"
    puts "  TESTING RUBY:#{RUBY_PLATFORM}"

    test_target = "test/test_src"
    test_src = "test/cases"
    dir_list = ["/iax/common/",
                "/iax/",
                "/iax/log/"]
    file_list = [["validator.rb"],
                 ["cmd_spec.rb", "log_spec.rb", "retry_spec.rb"],
                 ["default_record_formatter_spec.rb"]]

    remove_dir(test_target)
    puts "  make report folder\n"

    copy_test_code(test_src, dir_list, file_list, test_target)

    puts "preparation end======================\n\n"
  end

  ################################################
  # Rspecテストタスク:unit_test_ruby
  ################################################
  begin
    RSpec::Core::RakeTask.new("unit_test_ruby") do |t|
      time_formats = Time.now.strftime("%Y%m%d%H%M%S")
      t.pattern = File.dirname(__FILE__) + "/test/test_src/**/*_spec.rb"
      t.rspec_opts = ["-f d"]
      t.fail_on_error = false
    end
  rescue =>e
  end

  ################################################
  # RSpecテストタスクを宣言
  ################################################
  task :spec_test_core =>["build_folder_core", "unit_test_ruby"]
end
