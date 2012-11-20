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
  s.version = '1.2.1'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'batch framework'
  s.description = ''
  s.author = 'fetaro'
  s.email = 'fetaro@gmail.com'
  s.homepage = 'https://github.com/fetaro/rbatch'
  s.files = %w(LICENSE README.md README.ja.md Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"

end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.package_files.include("lib/**/*")
  p.need_tar = false
  p.need_zip = false
end

Rake::RDocTask.new do |rdoc|
  files =['README.md', 'LICENSE', 'CHANGELOG', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
#  rdoc.main = "README.md" # page to start on
  rdoc.title = "RBatch Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end


Rake::TestTask.new do |t|
  t.libs << "./lib"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc "Special Test for RBatch::log"
task :test_log do |t|
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"lib"))
  require "rbatch"
  path = File.join("test","special","bin","test_log.rb")
  RBatch.program_name = path
  load path
end

desc "Special Test for RBatch.config"
task :test_config do |t|
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"lib"))
  require "rbatch"
  path = File.join("test","special","bin","test_config.rb")
  RBatch.program_name = path
  load path
end
