include:
  - sudo


{{ sls }} add dangerdev:
  file.managed:
    - name: /etc/sudoers.d/dangerdev
    - source: salt://sudo/files/dangerdev
    - mode: '0440'
    - require:
      - pkg: sudo installed packages
    # Reminder: file.managed check_cmd is different than requisite check_cmd
    - check_cmd: /usr/sbin/visudo -csf
