# SpinupEC2Instance
Spin up an EC2 Instance and test it

### Description ###

This repo has two Ruby projects.

1. ec2spinner - It creates an EC2 instance with a web server. Tested using rspec for home page response.

2. testec2 - It uses awspec to test if EC2 resources are created.


### Dependencies and how to get started ####


Add spec/secrets.yml for both the projects with following content:

```sh
 aws_access_key_id: <YOUR ACCESS KEY ID GOES HERE>
 aws_secret_access_key: <YOUR SECRET ACCESS KEY GOES HERE>
 region: <ANY REGION GOES HERE>
```


> gem install bundler
 
> bundle install
 
> bundle exec rake spec

And, Ruby executable, of course!


### How to run tests #####

Run the following from ec2spinner or testec2 project home folder:

> bundle exec rake spec


### Single command to launch environment #####

Assuming all dependencies are installed and secrets.yml file is added, run the following from ec2spinner project home folder:

> ruby -r "./lib/ec2spinner.rb" -e "Ec2spinner.spinup"


### Test Run #####

```sh
> bundle exec rake spec
```


```sh
C:/Ruby24-x64/bin/ruby.exe -I'C:/Ruby24-x64/lib/ruby/gems/2.4.0/gems/rspec-core-3.7.0/lib';'C:/Ruby24-x64/lib/ruby/gems/2.4.0/gems/rspec-support-3.7.0/lib' 'C:/Ruby24-x64/lib/ruby/gems/2.4.0/gems/rspec-core-3.7.0/exe/rspec' --pattern 'spec/**{,/*/**}/*_spec.rb'
Created VPC. VPC_ID==>vpc-78bcaf11
Created Internet Gateway. IGW_ID==>igw-cbf7bea2
Create subnet. SUBNET_ID==>subnet-a5ddbce8
Created Route table. table.id==>rtb-adef13c5
Created Security Group. SECURITY_GROUP_ID==>sg-162c5f7e
A key pair named 'my-key-pair' already exists.
Created instance named 'MyInstance'. Waiting until public DNS is available...
Your new Web Server home page is: http://13.58.84.246/index.html
Your new Web Server home page (http://13.58.84.246/index.html) returns: To infiniti and beyond!

EC2 web server home page response
  should return: To infiniti and beyond!

Finished in 0 seconds (files took 1 minute 20.77 seconds to load)
1 example, 0 failures
```
