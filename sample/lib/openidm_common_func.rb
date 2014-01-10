# -*- coding: utf-8 -*-
require 'rbatch'

require 'net/http'
require 'net/http/post/multipart'

# Send file-upload request to OpenIDM
#  @param category : openidf file category
#  @param filepath : file
#  @param log : RBatch::Log instance
#
# do same
# curl --header "X-OpenIDM-Username: openidm-admin" --header "X-OpenIDM-Password: openidm-admin" -F file=@"D:\test.pdf" "http://localhost:8080/openidm/filerepo/cat/?_action=upload&save=true"
def store_file_to_openidm(category,filepath,log)
  server = RBatch.common_config["openidm"]["server"]
  port = RBatch.common_config["openidm"]["port"]
  path = "/openidm/filerepo/#{category}/?_action=upload&save=true"
  param = "_action=upload&save=true"
  headers = {
    "X-OpenIDM-Username" => RBatch.common_config["openidm"]["api_user"],
    "X-OpenIDM-Password" => RBatch.common_config["openidm"]["api_pass"]
  }
  File.open(filepath) do |file|
    http = Net::HTTP.new(server,port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post::Multipart.new(
        path,
        {"file" => UploadIO.new(file, "image/jpeg", "image.jpg")},
        headers)
    
    log.info("upload file: " + file.path)
    log.info("post url: http://#{server}:#{port}#{path}" )
    log.info("header: #{request.to_hash}" )
   
    response = http.request(request) #send request
    
    log.info("response code: #{response.message} #{response.code}")
    response.body.split("\n").each {|l| log.info("response body: #{l}")}
    if response.code == 200 || response.code == 201 || response.code == 202
      log.info("Success to upload file to OpenIDM");
    else
      raise "Faild to upload file to OpenIDM"
    end
  end
end
