{% import_yaml "5_HST__POD/biztool__prod/secrets.yaml" as biztool__prod -%}
{% import_yaml "5_HST__POD/chapters__prod/secrets.yaml" as chapters__prod -%}


include:
  - 5_HST__POD.index__prod.secrets
  - 5_HST__POD.index__stage.secrets


infra:
  orch.aws.rds:
    engine:
      # Default
      default: mariadb
      # Specific (please maintain order)
    engine_family:
      # List valid engine families:
      #
      #   aws --output text --region us-east-2 rds \
      #     describe-db-engine-versions \
      #     --query 'DBEngineVersions[].DBParameterGroupFamily' \
      #     --engine mariadb | sed -e's/\t/\n/g' | sort -uV
      #
      # Notes:
      # - The command above is for MariaDB. Replace "mariadb" with "postgres"
      #   for PostgreSQL.
      #
      # Default
      default: mariadb10.11
      # Specific (please maintain order)
    engine_version:
      # List valid engine versions:
      #
      #   aws --output text --region us-east-2 rds \
      #     describe-db-engine-versions \
      #     --query 'DBEngineVersions[].EngineVersion' \
      #     --engine mariadb | sed -e's/\t/\n/g' | sort -uV
      #
      # Notes:
      # - Be ware that MariaDB Engine Version on AWS only uses major and minor
      #   versions parts. For example, for MariaDB 10.3.23, simply use "10.3".
      # - The command above is for MariaDB. Replace "mariadb" with "postgres"
      #   for PostgreSQL.
      #
      # * Deprecation of db engine version 10.3, 10.4, & 10.6
      # Recommended migration: 10.4 --> 10.11  
      #                        10.6 --> 10.11
      # Default
      default: 10.11
      # Specific (please maintain order)
    instance_class:
      # Notes:
      # * DB Instance class db.t2.micro does not support encryption at rest
      #
      # Default
      default: db.t4g.small
      # Specific (please maintain order)
      chapters: db.t4g.medium
      index__prod: db.t4g.medium
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
      chapters__prod: {{ chapters__prod.mysql.server.root_password }}
    primary_username:
      # Default
      default: root
      # Specific (please maintain order)
      biztool__prod: {{ biztool__prod.mysql.server.root_user }}
      chapters__prod: {{ chapters__prod.mysql.server.root_user }}
    rds_secgroups:
      # Default
      default:
        - mysql-from-private_core_secgroup
      # Specific (please maintain order)
      biztool__prod:
        - mysql-from-biztool_prod_secgroup
      index__prod:
        - mysql-from-index_prod_secgroup
      index__stage:
        - mysql-from-index_stage_secgroup
      chapters__prod:
        - mysql-from-chapters_prod_secgroup
    storage:
      # Default
      default: 10
      # Specific (please maintain order)
      index: 334
      chapters: 334
    rds_subnets:
      default:
        - private-one_core_subnet
        - private-two_core_subnet
