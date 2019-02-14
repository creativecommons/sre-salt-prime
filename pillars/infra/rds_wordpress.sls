{% set HST, POD, LOC = grains.id.split("__") -%}
{% import_yaml "5_HST__POD/chapters__prod/secrets.yaml" as chapters__prod -%}
{% import_yaml "5_HST__POD/podcast__prod/secrets.yaml" as podcast__prod -%}


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
      # DB Instance class db.t2.micro does not support encryption at rest
      default: db.t2.small
      chapters: db.t2.medium
    parameters:
      default:
        character_set_server: utf8mb4
        collation_server: utf8mb4_general_ci
        innodb_log_file_size: 268435456 # 256 MiB
        time_zone: UTC
    primary_password:
      default: '/@@/ INVALID - MUST SET NON-DEFAULT PASSWORD /@@/'
      chapters__prod: {{ chapters__prod.mysql.server.root_password }}
      podcast__prod: {{ podcast__prod.mysql.server.root_password }}
    primary_username:
      default: root
      chapters__prod: {{ chapters__prod.mysql.server.root_user }}
      podcast__prod: {{ podcast__prod.mysql.server.root_user }}
    rds_secgroups:
      default:
        - mysql-from-private_core_secgroup
      chapters__prod:
        - mysql-from-chapters_prod_secgroup
      podcast__prod:
        - mysql-from-podcast_prod_secgroup
    storage:
      default: 10
      chapters: 334
    rds_subnets:
      default:
        - private-one_core_subnet
        - private-two_core_subnet
