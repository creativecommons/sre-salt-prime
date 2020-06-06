{% set HST, POD, LOC = grains.id.split("__") -%}
{% import_yaml "5_HST__POD/biztool__prod/secrets.yaml" as biztool__prod -%}
{% import_yaml "5_HST__POD/ccorgwp__stage/secrets.yaml" as ccorgwp__stage -%}
{% import_yaml "5_HST__POD/chapters__prod/secrets.yaml" as chapters__prod -%}
{% import_yaml "5_HST__POD/chapters__stage/secrets.yaml" as chapters__stage -%}
{% import_yaml "5_HST__POD/openglam__prod/secrets.yaml" as openglam__prod -%}
{% import_yaml "5_HST__POD/podcast__prod/secrets.yaml" as podcast__prod -%}
{% import_yaml "5_HST__POD/sotc__prod/secrets.yaml" as sotc__prod -%}
{% import_yaml "5_HST__POD/summit__prod/secrets.yaml" as summit__prod -%}


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
      # Default
      default: db.t2.small
      # Specific (please maintain order)
      chapters: db.t2.medium
    parameters:
      default:
        character_set_server: utf8mb4
        collation_server: utf8mb4_general_ci
        innodb_log_file_size: 268435456 # 256 MiB
        time_zone: UTC
    primary_password:
      # Default
      default: '/@@/ INVALID - MUST SET NON-DEFAULT PASSWORD /@@/'
      # Specific (please maintain order)
      biztool__prod: {{ biztool__prod.mysql.server.root_password }}
      ccorgwp__stage: {{ ccorgwp__stage.mysql.server.root_password }}
      chapters__prod: {{ chapters__prod.mysql.server.root_password }}
      chapters__stage: {{ chapters__stage.mysql.server.root_password }}
      openglam__prod: {{ openglam__prod.mysql.server.root_password }}
      podcast__prod: {{ podcast__prod.mysql.server.root_password }}
      sotc__prod: {{ sotc__prod.mysql.server.root_password }}
      summit__prod: {{ summit__prod.mysql.server.root_password }}
    primary_username:
      # Default
      default: root
      # Specific (please maintain order)
      biztool__prod: {{ biztool__prod.mysql.server.root_user }}
      ccorgwp__stage: {{ ccorgwp__stage.mysql.server.root_user }}
      chapters__prod: {{ chapters__prod.mysql.server.root_user }}
      chapters__stage: {{ chapters__stage.mysql.server.root_user }}
      openglam__prod: {{ openglam__prod.mysql.server.root_user }}
      podcast__prod: {{ podcast__prod.mysql.server.root_user }}
      sotc__prod: {{ sotc__prod.mysql.server.root_user }}
      summit__prod: {{ summit__prod.mysql.server.root_user }}
    rds_secgroups:
      # Default
      default:
        - mysql-from-private_core_secgroup
      # Specific (please maintain order)
      biztool__prod:
        - mysql-from-biztool_prod_secgroup
      ccorgwp__stage:
        - mysql-from-wordpress_stage_secgroup
      chapters__prod:
        - mysql-from-chapters_prod_secgroup
      chapters__stage:
        - mysql-from-chapters_stage_secgroup
      openglam__prod:
        - mysql-from-openglam_prod_secgroup
      podcast__prod:
        - mysql-from-podcast_prod_secgroup
      sotc__prod:
        - mysql-from-sotc_prod_secgroup
      summit__prod:
        - mysql-from-summit_prod_secgroup
    storage:
      # Default
      default: 10
      # Specific (please maintain order)
      chapters: 334
      openglam: 214
      wordpress: 214
    rds_subnets:
      default:
        - private-one_core_subnet
        - private-two_core_subnet
