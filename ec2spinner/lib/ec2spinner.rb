require "ec2spinner/version"
require 'aws-sdk-ec2'
require 'base64'
require 'eat'
require 'yaml'


module Ec2spinner
  def self.spinup

#    puts Dir.pwd
#    puts "hello from Ec2spinnerdo"
#    puts $LOAD_PATH

    @secrets_path ||= "spec/secrets.yml"
    creds = YAML.load_file(@secrets_path) if File.exist?(File.expand_path(@secrets_path))
    @region ||= creds['region'] if creds && creds.include?('region')
    return unless creds &&
        creds.include?('aws_access_key_id') &&
        creds.include?('aws_secret_access_key')
    @access_key_id     ||= creds['aws_access_key_id']
    @secret_access_key ||= creds['aws_secret_access_key']

#    puts @access_key_id
#    puts @secret_access_key


    Aws.config.update({
                        credentials: Aws::Credentials.new(@access_key_id, @secret_access_key)
                      })

    #### vpc

    ec2 = Aws::EC2::Resource.new(region: @region)

    vpc = ec2.create_vpc({ cidr_block: '10.200.0.0/16' })

    # So we get a public DNS
    vpc.modify_attribute({
                             enable_dns_support: { value: true }
                         })

    vpc.modify_attribute({
                             enable_dns_hostnames: { value: true }
                         })

    # Name our VPC
    vpc.create_tags({ tags: [{ key: 'Name', value: 'MyVPC' }]})

    _VPC_ID = vpc.vpc_id
    puts "Created VPC. VPC_ID==>#{_VPC_ID}"

    ##### internet gateway

    igw = ec2.create_internet_gateway

    igw.create_tags({ tags: [{ key: 'Name', value: 'MyIGW' }]})
    igw.attach_to_vpc(vpc_id: _VPC_ID)

    _IGW_ID = igw.id
    puts "Created Internet Gateway. IGW_ID==>#{_IGW_ID}"

    ###### public subnet

    subnet = ec2.create_subnet({
                                   vpc_id: _VPC_ID,
                                   cidr_block: '10.200.10.0/24'
#                                   ,availability_zone: 'us-east-2a'
                               })

    subnet.create_tags({ tags: [{ key: 'Name', value: 'MySubnet' }]})
    _SUBNET_ID = subnet.id
    puts "Create subnet. SUBNET_ID==>#{_SUBNET_ID}"


    ##### route table


    table = ec2.create_route_table({
                                       vpc_id: _VPC_ID
                                   })

    table.create_tags({ tags: [{ key: 'Name', value: 'MyRouteTable' }]})

    table.create_route({
                           destination_cidr_block: '0.0.0.0/0',
                           gateway_id: _IGW_ID
                       })

    table.associate_with_subnet({
                                    subnet_id: _SUBNET_ID
                                })

    puts "Created Route table. table.id==>#{table.id}"


    ####### security group

    sg = ec2.create_security_group({
                                       group_name: 'MySecurityGroup',
                                       description: 'Security group for EC2 Linux Webserver Instance',
                                       vpc_id: _VPC_ID
                                   })

    sg.authorize_egress({
                            ip_permissions: [{
                                                 ip_protocol: 'tcp',
                                                 from_port: 22,
                                                 to_port: 22,
                                                 ip_ranges: [{
                                                                 cidr_ip: '0.0.0.0/0'
                                                             }]
                                             }]
                        })

    sg.authorize_ingress({
                             ip_permissions: [{
                                                  ip_protocol: 'tcp',
                                                  from_port: 80,
                                                  to_port: 80,
                                                  ip_ranges: [{
                                                                  cidr_ip: '0.0.0.0/0'
                                                              }]
                                              }]
                         })


    _SECURITY_GROUP_ID = sg.id
    puts "Created Security Group. SECURITY_GROUP_ID==>#{_SECURITY_GROUP_ID}"


    ### key pair
    begin
      key_pair_name = "my-key-pair"
      key_pair = ec2.create_key_pair({
                                         key_name: key_pair_name
                                     })
      puts "Created key pair named '#{key_pair_name}'."
    rescue Aws::EC2::Errors::InvalidKeyPairDuplicate
      puts "A key pair named '#{key_pair_name}' already exists."
    end


    # User code that's executed when the instance starts
    script = '#!/bin/bash
yum update -y
yum install -y httpd
service httpd start
chkconfig httpd on
groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +
echo "To infiniti and beyond!" > /var/www/html/index.html
'

    encoded_script = Base64.encode64(script)

    #ec2 = Aws::EC2::Resource.new(region: @region)


    instances = ec2.create_instances({
                                         image_id: 'ami-c5062ba0',
                                         min_count: 1,
                                         max_count: 1,
                                         key_name: key_pair_name,
                                         #                                    security_group_ids: ['_SECURITY_GROUP_ID'],
                                         user_data: encoded_script,
                                         instance_type: 't2.micro',
#                                         placement: {
#                                             availability_zone: 'us-east-2a'
#                                         },
                                         #                                    subnet_id: _SUBNET_ID,
                                         network_interfaces: [{device_index: 0,
                                                               subnet_id: _SUBNET_ID,
                                                               groups: [_SECURITY_GROUP_ID],
                                                               delete_on_termination: true,
                                                               associate_public_ip_address: true}]
                                         #                                    iam_instance_profile: {
                                         #                                        arn: 'arn:aws:iam::512228695066:instance-profile/aws-opsworks-ec2-role'
                                         #                                    }
                                     })

    inst = instances.first()

    # Tag the instance
    inst.create_tags({ tags: [{ key: 'Name', value: 'MyInstance' }, { key: 'Group', value: 'MyGroup' }]})

    puts "Created instance named 'MyInstance'. Waiting until public DNS is available..."

    inst = inst.wait_until {|inst| !inst.public_dns_name.empty? }

#    puts "instance.id==>#{inst.instance_id}"
#    puts "instance.public_ip_address==>#{inst.public_ip_address}"
#    puts "instance.private_ip_address==>#{inst.private_ip_address}"
#    puts inst.inspect
     sleep(60)

    url = "http://#{inst.public_ip_address}/index.html"
    puts "Your new Web Server home page is: #{url}"
    response = eat(url, :timeout => 60)
    puts "Your new Web Server home page (#{url}) returns: #{response}"
    return response
  end
end
