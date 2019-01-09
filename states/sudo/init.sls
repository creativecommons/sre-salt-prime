{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - sudo


{{ sls }} add additional defaults:
  file.managed:
    - name: /etc/sudoers.d/defaults
    - source: salt://sudo/files/defaults
    - mode: '0440'
    - require:
      - pkg: {{ sls }} installed packages
    # Reminder: file.managed check_cmd is different than requisite check_cmd
    - check_cmd: /usr/sbin/visudo -csf
