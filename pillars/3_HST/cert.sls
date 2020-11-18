include:
  - letsencrypt
  - mysql
  - php
  - user.webdevs.secrets


letsencrypt:
  post_hooks:
    restart_apache2.sh: /usr/sbin/service apache2 reload
mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
states:
  mount: {{ sls }}
  php.mbstring: {{ sls }}
  user.webdevs: {{ sls }}
  wordpress.apache2: {{ sls }}
  wordpress.git_install: {{ sls }}
wordpress:
  docroot: /var/www/cert
  # Multisite
  multisite: True
  subdomain_install: False
  path_current_site: /
  site_id_current_site: 1
  blog_id_current_site: 1
  # for plugins and themes that are not available to be installed via composer
  git_install:
    # Plugins
    - name: advanced-custom-fields-pro
      rev: 5.8.7
      type: plugins
      repo: https://github.com/wp-premium/advanced-custom-fields-pro.git
    - name: candela-citation
      rev: 083e08a  # 2020-10-09
      type: plugins
      repo: https://github.com/lumenlearning/candela-citation.git
    - name: candela-lti
      rev: c2c60bc  # 2018-05-10
      type: plugins
      repo: https://github.com/lumenlearning/candela-lti.git
    - name: candela-thin-exports
      rev: 7a9c9ae  # 2018-02-16
      type: plugins
      repo: https://github.com/lumenlearning/candela-thin-exports.git
    - name: candela-utility
      rev: a666551  # 2019-06-16
      type: plugins
      repo: https://github.com/lumenlearning/candela-utility.git
    - name: lti
      rev: 95c1cb3  # 2018-06-20
      type: plugins
      repo: https://github.com/lumenlearning/lti.git
