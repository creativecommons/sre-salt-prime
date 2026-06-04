{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https


# Manual installation - nodesource/distributions/README.md
# https://github.com/nodesource/distributions/wiki/Repository-Manual-Installation
{% set VERSION = 24 -%}
{% set REPO_HOST = "https://deb.nodesource.com" -%}
{% set OS = grains['oscodename'] -%}
{{ sls }} Node.js Repository:
  pkgrepo.managed:
    - name: deb {{ REPO_HOST }}/node_{{ VERSION }}.x nodistro main
    - file: /etc/apt/sources.list.d/nodejs.list
    - key_url: {{ REPO_HOST }}/gpgkey/nodesource.gpg.key
    - clean_file: True
    - require:
      - pkg: {{ sls }} dependencies
    - require_in:
      - pkg: {{ sls }} installed packages


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - nodejs
