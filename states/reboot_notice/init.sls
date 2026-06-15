{{ sls }} reboot notice script:
  file.managed:
    - name: /usr/local/sbin/reboot_notice.sh
    - user: root
    - group: root
    - mode: '0555'
    - source: salt://reboot_notice/files/reboot_notice.sh
    - require:
      - file: postfix main.cf


{{ sls }} reboot notice cron:
  cron.present:
    - name: /usr/local/sbin/reboot_notice.sh
    - user: root
    - identifier: reboot_notice
    - minute: 59
    - hour: 23
    - require:
      - file: {{ sls }} reboot notice script
