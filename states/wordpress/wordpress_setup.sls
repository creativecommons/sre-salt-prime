{{ sls }} install script:
  file.managed:
    - name: /usr/local/bin/wpcli.sh
    - source: salt://wordpress/files/wpcli.sh
    - mode: '0775'


{{ sls }} daily backup cron job:
  cron.present:
    - name: '/usr/local/bin/wpcli.sh >/dev/null'
    - user: root
    - identifier: wpcli
    - minute: 5
    - hour: 17
    - dayweek: Wed
    - require:
      - file: {{ sls }} install script
      - group: user.webdevs webdev group
      - user: php_cc.composer user
