include:
  - apache2


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - libapache2-mod-fcgid
    - require:
      - pkg: apache2 installed packages


{{ sls }} enable mod fcgid:
  apache_module.enabled:
    - name: fcgid
    - require:
      - pkg: {{ sls }} installed packages
    - watch_in:
      - service: apache2 service
