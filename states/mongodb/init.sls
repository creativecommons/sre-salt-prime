{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - python-apt


# Install MongoDB Community Edition on Debian — MongoDB Manual
# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/
{% set repo_host = "https://deb.nodesource.com" -%}
{{ sls }} MongerDB-org-4.0 Repository:
  pkgrepo.managed:
    - name: deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main
    - file: /etc/apt/sources.list.d/mongodb-org-4.0.list
    - key_url: https://www.mongodb.org/static/pgp/server-4.0.asc
    - clean_file: True
    - require:
      - pkg: {{ sls }} dependencies
    - require_in:
      - pkg: {{ sls }} installed packages


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - mongodb-org-server
      - mongodb-org-tools


{{ sls }} /srv/mongodb directory:
  file.directory:
    - name: /srv/mongodb
    - user: mongodb
    - group: mongodb
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - {{ sls }} service


{{ sls }} symlink /var/lib/mongodb directory:
  file.symlink:
    - name: /var/lib/mongodb
    - target: /srv/mongodb
    - force: True
    - backupname: /var/lib/mongodb.{{ None|strftime("%Y%m%d_%H%M%S") }}
    - require:
      - file: {{ sls }} /srv/mongodb directory
    - watch_in:
      - {{ sls }} service


{{ sls }} /etc/mongod.conf:
  file.managed:
    - name: /etc/mongod.conf
    - source: salt://mongodb/files/mongod.conf
    - mode: '0444'
    - require:
      - file: {{ sls }} /srv/mongodb directory
    - watch_in:
      - {{ sls }} service


{{ sls }} service:
  service.running:
    - name: mongod
    - enable: True
    - require:
      - pkg: {{ sls }} installed packages
