{% set DIR_REPO = "/var/www/cc-licenses" -%}
{% set DIR_DOCROOT = "{}/docroot".format(DIR_REPO) -%}
{% set DIR_VENV = "{}/venv".format(DIR_REPO) -%}

mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
cc_licenses:
  docroot: {{ DIR_DOCROOT }}
  log: {{ DIR_REPO }}/log
  media: {{ DIR_DOCROOT }}/media
  repo: {{ DIR_REPO }}
  static: {{ DIR_DOCROOT }}/static
  static_origin: {{ DIR_REPO }}/cc_licenses/static
  venv: {{ DIR_VENV }}
  portfile: /tmp/gunicron_portfile
nginx:
  flavor: light
states:
  django.cclicdev: {{ sls }}
  mount: {{ sls }}
  nginx.cclicdev: {{ sls }}
  postgres_cc.user_clusters: {{ sls }}
