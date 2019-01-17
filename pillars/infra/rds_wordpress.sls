infra:
  orch.aws.rds_wordpress:
    family:
      # cmd: aws --region us-east-2 rds describe-db-engine-versions \
      #       --query "DBEngineVersions[].DBParameterGroupFamily"
      default: mariadb10.3
    instance_class:
      default: t3.small
      chapters: t3.medium
    parameters:
      default:
        character_set_server: utf8mb4
        collation_server: utf8mb4_general_ci
        innodb_log_file_size: 268435456 # 256 MiB
        time_zone: UTC
    secgroups:
      default:
        - mysql-from-private_core_secgroup
      chapters:
        - mysql-from-chapters_core_secgroup
    size:
      default: 10
      chapters: 334
    subnets:
      default:
        - private-one_core_subnet
        - private-two_core_subnet
