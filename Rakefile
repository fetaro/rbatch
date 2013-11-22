require "bundler/gem_tasks"

desc "Test lib/ by using test/cases/test_*.rb"
task :test do
  result = 0
  cases = FileList["test/cases/*.rb"]
  cases.each do | c |
    cmd_str="ruby -I lib #{c}"
    stdout_file = Tempfile::new("rbatch_tmpout",".")
    stderr_file = Tempfile::new("rbatch_tmperr",".")
    pid = spawn(cmd_str,:out => [stdout_file,"w"],:err => [stderr_file,"w"])
    status =  Process.waitpid2(pid)[1] >> 8
    puts ""
    puts "> " + cmd_str
    puts "------------------------------"
    puts File.read(stdout_file)
    puts "------------------------------"
    if status != 0
      result = 1
    end
  end
  if result == 0
    puts "\nTest Success \n"
  else
    puts "\nTest Failed \n"
  end
  exit result
end
