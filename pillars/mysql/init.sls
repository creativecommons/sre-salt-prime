mysql:
  config_directory: /etc/mysql/conf.d/
  global:
    client-server:
      default_character_set: utf8mb4
  clients:
    mysql:
      default_character_set: utf8mb4
    mysqldump:
      default_character_set: utf8mb4
  library:
    client:
      default_character_set: utf8mb4
