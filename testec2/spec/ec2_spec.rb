require 'spec_helper'

describe ec2('MyInstance') do
  it { should exist }
  it { should be_running }
  its(:image_id) { should eq 'ami-c5062ba0' }
  its(:instance_type) { should eq 't2.micro' }
  it { should have_security_group('MySecurityGroup') }
end
