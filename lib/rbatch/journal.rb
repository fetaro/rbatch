module RBatch
  # @private
  class Journal
    @@def_vars
    def Journal.def_vars=(a) ; @@def_vars=a ; end 
    attr :journals,:journal_verbose,:user_logs
    def initialize(verbose=nil)
      if ! verbose.nil?
        @journal_verbose = verbose
      else
        @journal_verbose = @@def_vars[:rbatch_journal_level]
      end
      @journals = []
      @user_logs = []
    end
    def put(level,str)
      if level <= @journal_verbose
        @journals << str
        str = "[RBatch] " + str
        puts str
        @user_logs.each do |log|
          if @@def_vars[:mix_rbatch_journal_to_logs]
            log.journal(str)
          end
        end
      end
    end
    def add_log(log)
      @user_logs << log
      if @@def_vars[:mix_rbatch_journal_to_logs]
        @journals.each do |j|
          log.journal(j)
        end
      end
    end
  end
end
