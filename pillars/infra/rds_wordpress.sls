infra:
  orch.aws.rds_wordpress:
    engine:
      default: mariadb
    engine_family:
      # cmd: aws --region us-east-2 rds describe-db-engine-versions \
      #       --query "DBEngineVersions[].DBParameterGroupFamily"
      default: mariadb10.3
    engine_version:
      default: 10.3
    instance_class:
      default: db.t2.small
      chapters: db.t2.medium
    parameters:
      default:
        character_set_server: utf8mb4
        collation_server: utf8mb4_general_ci
        innodb_log_file_size: 268435456 # 256 MiB
        time_zone: UTC
    primary_password:
      default: '/@@/ INVALID - SET NONDEFAULT IN SECRETS /@@/'
    primary_username:
      default: root
    secgroups:
      default:
        - mysql-from-private_core_secgroup
      chapters:
        - mysql-from-chapters_core_secgroup
    storage:
      default: 10
      chapters: 334
    subnets:
      default:
        - private-one_core_subnet
        - private-two_core_subnet
