module RBatch
  class Journal
    attr :journal_verbose,:user_logs
    def initialize(verbose=nil)
      if verbose.nil?
        if ENV["RB_VERBOSE"]
          @journal_verbose = ENV["RB_VERBOSE"].to_i
        else
          @journal_verbose = 1
        end
      else
        @journal_verbose = verbose
      end
      @journals = []
      @user_logs = []
    end
    def put(level,str)
      if level <= @journal_verbose
        str = "[RBatch] " + str
        puts str
        @journals << str
        @user_logs.each do |log|
          if RBatch.run_conf[:mix_rbatch_journal_to_logs]
            log.journal(str)
          end
        end
      end
    end
    def add_log(log)
      @user_logs << log
    end
  end
end
