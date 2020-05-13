include:
  - sudo


{{ sls }} add webdev:
  file.managed:
    - name: /etc/sudoers.d/webdev
    - source: salt://sudo/files/webdev
    - mode: '0440'
    - require:
      - group: user.webdevs webdev group
      - pkg: sudo installed packages
    # Reminder: file.managed check_cmd is different than requisite check_cmd
    - check_cmd: /usr/sbin/visudo -csf
