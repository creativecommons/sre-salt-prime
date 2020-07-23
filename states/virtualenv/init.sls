{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - python3-pip
      - python3-virtualenv
      # SaltStack v3000 virtualenv requires Python2 virtualenv, even when
      # Python3 is the only one used
      - virtualenv
