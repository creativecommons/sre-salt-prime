infra:
  # url: https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
  debian_ami_name: debian-stretch-hvm-x86_64-gp2-2018-11-10-63975
  debian_ami_id: ami-08e2234d40f32eb5c
  region: us-east-2
  salt_prime: 10.22.11.11
  # cmd: aws --region us-east-2 ec2 describe-vpcs
  vpc:
    name: us-east-2_core_vpc
    id: vpc-04cea7e4be82901e9
    cidr: 10.22.0.0/16
