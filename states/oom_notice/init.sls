{{ sls }} oom notice script:
  file.managed:
    - name: /usr/local/sbin/oom_notice.sh
    - user: root
    - group: root
    - mode: '0555'
    - source: salt://oom_notice/files/oom_notice.sh
    - require:
      - file: postfix main.cf


{{ sls }} oom notice cron:
  cron.present:
    - name: /usr/local/sbin/oom_notice.sh
    - user: root
    - identifier: oom_notice
    - minute: 59
    - hour: 23
    - require:
      - file: {{ sls }} oom notice script
