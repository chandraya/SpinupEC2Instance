# SpinupEC2Instance
Spin up an EC2 Instance and test it

### Description ###

This repo has two Ruby projects.

1. ec2spinner - It creates an EC2 instance with a web server. Tested using rspec for home page response.

2. testec2 - It tests if EC2 resources are created using awspec.


### Dependencies and how to get started ####


Add spec/secrets.yml for both the projects with following content:

 aws_access_key_id: <YOUR ACCESS KEY ID GOES HERE>
 aws_secret_access_key: <YOUR SECRET ACCESS KEY GOES HERE>
 region: <ANY REGION GOES HERE>


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


