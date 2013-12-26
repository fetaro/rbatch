require 'tmpdir'
require 'tempfile'
module RBatch
  module DoubleRunChecker
    module_function
    def lock_file_name(p)
      File.join("rbatch_lock_" + p)
    end

    def check(p)
      Dir::foreach(Dir.tmpdir) do |f|
        if Regexp.new(lock_file_name(p)) =~ f
          raise RBatch::DoubleRunCheckException, p + " is forbidden running doubly"
        end
      end
    end

    def make_lock_file(p)
      Tempfile::new(lock_file_name(p),Dir.tmpdir)
    end
  end

  class DoubleRunCheckException < Exception ; end
end
