require 'spec_helper'
require 'ec2spinner'

_response = Ec2spinner.spinup

describe "EC2 web server home page response" do
  it "should return: To infiniti and beyond!" do
    #_response.should eq("To infiniti and beyond!\n")
    expect(_response).to eq("To infiniti and beyond!\n")
  end
end