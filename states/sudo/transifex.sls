include:
  - sudo


{{ sls }} add transifex:
  file.managed:
    - name: /etc/sudoers.d/transifex
    - source: salt://sudo/files/transifex
    - mode: '0440'
    - require:
      - pkg: sudo installed packages
    # Reminder: file.managed check_cmd is different than requisite check_cmd
    - check_cmd: /usr/sbin/visudo -csf
