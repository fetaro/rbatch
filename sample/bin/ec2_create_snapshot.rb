require 'rbatch'

RBatch::Log.new do |log|
  require 'aws-sdk'
  require 'net/http'
  # get ec2 region
  @ec2_region = "ec2." +
    Net::HTTP.get("169.254.169.254", "/latest/meta-data/placement/availability-zone").chop +
    ".amazonaws.com"
  log.info("ec2 region : #{@ec2_region}")  # <= Output Log

  #create ec2 instance
  @ec2 = AWS::EC2.new(:access_key_id     => RBatch.config["access_key"],
                      :secret_access_key => RBatch.config["secret_key"],
                      :ec2_endpoint      => @ec2_region)


  # create instance
  @instance_id = Net::HTTP.get("169.254.169.254", "/latest/meta-data/instance-id")
  @instance = @ec2.instances[@instance_id]
  log.info("instance_id : #{@instance_id}")

  # create snapshots
  @instance.block_devices.each do | dev |
    desc = @instance_id + " " + dev[:device_name] + " " +
      dev[:ebs][:volume_id] + " " +Time.now.strftime("%Y/%m/%d %H:%M").to_s
    log.info("create snapshot : #{desc}")
    @ec2.volumes[dev[:ebs][:volume_id]].create_snapshot(desc)
    log.info("sucess")
  end
end

