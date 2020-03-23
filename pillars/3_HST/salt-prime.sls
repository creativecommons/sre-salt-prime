include:
  - 3_HST.wikijs.secrets
  - cloudflare.secrets
  - gandi.secrets
  - infra


location:
  salt_prime_ip: 127.0.0.1
mounts:
  - spec: /dev/xvdf
    file: /srv
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
salt:
  gitfs_remotes:
    - git@github.com:creativecommons/mysql-formula.git
    - git@github.com:creativecommons/php-formula.git
states:
  mount: {{ sls }}
  wikijs.reports: {{ sls }}
