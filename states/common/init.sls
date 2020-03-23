{%- if grains.virtual == "kvm" %}
include:
  - .virtual


{% endif -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - dnsutils
      - htop
      - nvme-cli
      - python-apt
      - rsync
      - silversearcher-ag
      - time
      - tree
