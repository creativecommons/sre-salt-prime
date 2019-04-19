infra:
  us-east-2:
    # url: https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
    debian_ami_name: debian-stretch-hvm-x86_64-gp2-2019-02-19-26620
    debian_ami_id: ami-00c5940f2b52c5d98
    instance_iam_role: ec2_core_iam_role
    kms_key_id_storage: storage_core_kmskey
    vendor: aws
    region: us-east-2
    salt_prime: 10.22.11.11
    # cmd: aws --region us-east-2 ec2 describe-vpcs
    vpc:
      name: us-east-2_core_vpc
      id: vpc-04cea7e4be82901e9
      cidr: 10.22.0.0/16
