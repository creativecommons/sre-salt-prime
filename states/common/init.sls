include:
  - .virtual
  - amazon.cloudwatch_agent


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - dnsutils
      - htop
      - nvme-cli
      - rsync
      - silversearcher-ag
      - time
      - tree
