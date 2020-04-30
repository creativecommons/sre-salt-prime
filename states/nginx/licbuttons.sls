{% import "nginx/jinja2.sls" as nginx with context -%}
{% set CERT_NAME = pillar.nginx.cert_name -%}
{% set NOW = None|strftime("%Y%m%d_%H%M%S") -%}


include:
  - nginx
  - nginx.custom_log_formats
  - letsencrypt


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git
      - gir1.2-pango-1.0
      - libnginx-mod-http-fancyindex
      - python3-gi-cairo
    - require:
      - pkg: nginx installed packages


{{ sls }} group:
  group.present:
    - name: licbuttons
    - system: True
{%- if pillar.mounts %}
    - require:
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}


{{ sls }} user:
  user.present:
    - name: licbuttons
    - gid_from_name: True
    - home: /srv
    - password: '!'
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: {{ sls }} group


{{ sls }} /srv/licensebuttons:
  file.directory:
    - name: /srv/licensebuttons
    - user: licbuttons
    - group: licbuttons
    - require:
      - user: {{ sls }} user


{{ sls }} licensebuttons repo:
  git.latest:
    - name: 'https://github.com/creativecommons/licensebuttons.git'
    - target: /srv/licensebuttons
    - rev: {{ pillar.git_branch }}
    - branch: {{ pillar.git_branch }}
    - user: licbuttons
    - fetch_tags: False
    - require:
      - pkg: {{ sls }} installed packages
      - user: {{ sls }} user


{{ sls }} /srv/.fonts:
  file.directory:
    - name: /srv/.fonts
    - user: licbuttons
    - group: licbuttons
    - require:
      - git: {{ sls }} licensebuttons repo


{{ sls }} /srv/.fonts/cc-icons.ttf:
  file.symlink:
    - name: /srv/.fonts/cc-icons.ttf
    - target: /srv/licensebuttons/www/cc-icons.ttf
    - require:
      - file: {{ sls }} /srv/.fonts


{{ sls }} generate icons:
  cmd.run:
    - name: /usr/bin/python3 /srv/licensebuttons/scripts/genicons.py
    - runas: licbuttons
    - onchanges:
      - git: {{ sls }} licensebuttons repo
    - require:
      - file: {{ sls }} /srv/.fonts/cc-icons.ttf


{{ sls }} install {{ CERT_NAME }}_basic site:
  file.managed:
    - name: /etc/nginx/sites-available/{{ CERT_NAME }}_basic
    - source: salt://nginx/files/licbuttons_basic_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
      - file: nginx.custom_log_formats custom log dir
      - file: nginx.custom_log_formats install conf custom_log_formats
    - watch_in:
      - service: nginx service


{{ sls }} install {{ CERT_NAME }}_tls site:
  file.managed:
    - name: /etc/nginx/sites-available/{{ CERT_NAME }}_tls
    - source: salt://nginx/files/licbuttons_tls_template
    - mode: '0444'
    - template: jinja
    - defaults:
        CERT_NAME: {{ CERT_NAME }}
        SLS: {{ sls }}
    - require:
      - pkg: nginx installed packages
      - file: nginx.custom_log_formats custom log dir
      - file: nginx.custom_log_formats install conf custom_log_formats
    - watch_in:
      - service: nginx service


{{ sls }} enable {{ CERT_NAME }}_basic site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ CERT_NAME }}_basic
    - target: /etc/nginx/sites-available/{{ CERT_NAME }}_basic
    - require:
      - file: {{ sls }} install {{ CERT_NAME }}_basic site
      - {{ sls }} disable site default
    - require_in:
      - pip: letsencrypt install certbot
    - watch_in:
      - service: nginx service


{{ sls }} enable {{ CERT_NAME }}_tls site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ CERT_NAME }}_tls
    - target: /etc/nginx/sites-available/{{ CERT_NAME }}_tls
    - require:
      - cron: letsencrypt cron certbot renew
      - file: {{ sls }} install {{ CERT_NAME }}_tls site
      - file: {{ sls }} enable {{ CERT_NAME }}_basic site
      - {{ sls }} disable site default
    - onlyif:
      - test -f /etc/letsencrypt/live/{{ CERT_NAME }}/fullchain.pem
    - watch_in:
      - service: nginx service


{{ nginx.disable_sites(sls, ["default"]) -}}
