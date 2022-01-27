{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https


# Install MongoDB Community Edition on Debian — MongoDB Manual
# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-debian/
{%- set repo_host = "https://repo.mongodb.org" %}
{%- set os = grains['oscodename'] %}
{%- if os == "stretch" %}
  {%- set ver = "4.0" %}
{%- else %}
  {%- set ver = "4.2" %}
{%- endif %}
{{ sls }} MongerDB-org-{{ ver }} Repository:
  pkgrepo.managed:
    - name: deb {{ repo_host }}/apt/debian {{ os }}/mongodb-org/{{ ver }} main
    - file: /etc/apt/sources.list.d/mongodb-org-{{ ver }}.list
    - key_url: https://www.mongodb.org/static/pgp/server-{{ ver }}.asc
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
