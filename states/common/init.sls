{{ sls }} install packages:
  pkg.installed:
    - pkgs:
      - dnsutils
      - htop
      - rsync
      - salt-doc
      - tree
      - vim-nox
