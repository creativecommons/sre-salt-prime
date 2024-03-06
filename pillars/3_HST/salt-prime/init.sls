include:
  - 3_HST.salt-prime.secrets
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
    mysql-formula:
      url: https://github.com/saltstack-formulas/mysql-formula.git
      refs:
        base: v0.56.6
    php-formula:
      url: https://github.com/saltstack-formulas/php-formula.git
      refs:
        base: v1.6.0
states:
  mount: {{ sls }}
  wikijs.all_reports: {{ sls }}
