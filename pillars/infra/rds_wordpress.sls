{% set HST, POD, LOC = grains.id.split("__") -%}
{% import_yaml "5_HST__POD/chapters__core/secrets.yaml" as chapters__core %}


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
      default: '/@@/ INVALID - MUST SET NON-DEFAULT PASSWORD /@@/'
      chapters__core: {{ chapters__core.mysql.server.root_password }}
    primary_username:
      default: root
      chapters__core: {{ chapters__core.mysql.server.root_user }}
    rds_secgroups:
      default:
        - mysql-from-private_{{ POD }}_secgroup
      chapters:
        - mysql-from-chapters_{{ POD }}_secgroup
    storage:
      default: 10
      chapters: 334
    rds_subnets:
      default:
        - private-one_core_subnet
        - private-two_core_subnet
