include:
  - .virtual


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
