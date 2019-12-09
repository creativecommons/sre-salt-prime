# Configuration for mysql-formula
# https://github.com/creativecommons/mysql-formula
{% set DEFAULT_CHARACTER_SET = "utf8mb4" -%}


mysql:
  config_directory: /etc/mysql/conf.d/
  default_character_set: {{ DEFAULT_CHARACTER_SET }}
  default_collate: utf8mb4_general_ci
  clients:
    mysql:
      default_character_set: {{ DEFAULT_CHARACTER_SET }}
    mysqldump:
      default_character_set: {{ DEFAULT_CHARACTER_SET }}
  global:
    client-server:
      default_character_set: {{ DEFAULT_CHARACTER_SET }}
  library:
    client:
      default_character_set: {{ DEFAULT_CHARACTER_SET }}
