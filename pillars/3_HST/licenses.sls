{% set DIR_REPO = "/var/www/cc-licenses" -%}
{% set DIR_PUBLIC = "{}/public".format(DIR_REPO) -%}
{% set DIR_VENV = "{}/venv".format(DIR_REPO) -%}

mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
cc_licenses:
  log: {{ DIR_REPO }}/log
  media: {{ DIR_PUBLIC }}/media
  portfile: /tmp/gunicron_portfile
  public: {{ DIR_PUBLIC }}
  repo: {{ DIR_REPO }}
  static: {{ DIR_PUBLIC }}/static
  static_origin: {{ DIR_REPO }}/cc_licenses/static
  venv: {{ DIR_VENV }}
nginx:
  flavor: light
states:
  django.licenses: {{ sls }}
  mount: {{ sls }}
  nginx.licenses: {{ sls }}
  postgres_cc.user_clusters: {{ sls }}
