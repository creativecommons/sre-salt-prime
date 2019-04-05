{{ sls }} dependencies:
  pkg.installed:
    - pkgs:
      - python-apt


# Manual installation - nodesource/distributions/README.md
# https://github.com/nodesource/distributions/blob/master/README.md#manual-installation
{% set repo_host = "https://deb.nodesource.com" -%}
{{ sls }} Node.js Repository:
  pkgrepo.managed:
    - name: deb {{ repo_host }}/node_11.x stretch main
    - file: /etc/apt/sources.list.d/nodejs.list
    - key_url: {{ repo_host }}/gpgkey/nodesource.gpg.key
    - clean_file: True
    - require:
      - pkg: {{ sls }} dependencies
    - require_in:
      - pkg: {{ sls }} installed packages


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - nodejs
