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

Rake::TestTask.new do |t|
  t.libs << "./lib"
  t.test_files = FileList['test/test*.rb','test/**/test*.rb']
  t.verbose = true
end