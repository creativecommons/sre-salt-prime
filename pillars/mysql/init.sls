# Configuration for mysql-formula
{% set DEFAULT_CHARACTER_SET = "utf8mb4" -%}


# The configuration below assumes Debian and the mysql_cc.debian_integration
# state is applied.
mysql:
  clientpkg: mariadb-client
  config_directory: /etc/mysql/conf.d/
  default_character_set: {{ DEFAULT_CHARACTER_SET }}
  default_collate: utf8mb4_general_ci
  library_config:
    file: client.cnf
    sections:
      client:
        default_character_set: {{ DEFAULT_CHARACTER_SET }}
  clients_config:
    file: mysql-clients.cnf
    sections:
      mysql:
        default_character_set: {{ DEFAULT_CHARACTER_SET }}
      mysqldump:
        default_character_set: {{ DEFAULT_CHARACTER_SET }}
        max_allowed_packet: 16M
        quick: noarg_present
        quote_names: noarg_present
