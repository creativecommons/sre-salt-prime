infra:
  us-east-2:
    # url: https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye
    debian_ami_name: debian-12-amd64-20240702-1796
    debian_ami_id: ami-0002aa901e88cc81d8
    instance_iam_role: ec2_core_iam_role
    kms_key_id_storage: storage_core_kmskey
    vendor: aws
    region: us-east-2
    salt_prime: 10.22.11.11
    vpc:
      # cmd: aws --region us-east-2 ec2 describe-vpcs
      name: us-east-2_core_vpc
      id: vpc-04cea7e4be82901e9
      cidr: 10.22.0.0/16
