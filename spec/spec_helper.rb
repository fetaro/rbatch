require 'tmpdir'
@HOME_DIR = File.join(Dir.tmpdir, "rbatch_test_" + Time.now.strftime("%Y%m%d%H%M%S"))
Dir.mkdir(@HOME_DIR)
ENV["RB_HOME"]=@HOME_DIR
ENV["RB_VERBOSE"]="0"
