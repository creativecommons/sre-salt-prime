include:
  - sudo


{{ sls }} add letsencrypt:
  file.managed:
    - name: /etc/sudoers.d/letsencrypt
    - source: salt://sudo/files/letsencrypt
    - mode: '0440'
    - require:
      - pkg: sudo installed packages
    # Reminder: file.managed check_cmd is different than requisite check_cmd
    - check_cmd: /usr/sbin/visudo -csf
