{{ sls }} install script:
  file.managed:
    - name: /usr/local/sbin/norm_wp_perms.sh
    - source: salt://wordpress/files/norm_wp_perms.sh
    - mode: '0555'


{{ sls }} daily backup cron job:
  cron.present:
    - name: '/usr/local/sbin/norm_wp_perms.sh >/dev/null'
    - user: root
    - identifier: norm_wp_perms
    - minute: 5
    - hour: 17
    - dayweek: Wed
    - require:
      - file: {{ sls }} install script
      - group: user.webdevs webdev group
      - user: php_cc.composer user
