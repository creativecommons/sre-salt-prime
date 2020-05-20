# WARNINGS:
# - If you updated the user/group within this file, be sure to also update the
#   states/wordpress/files/norm_wp_perms.sh script
#
{% set DOCROOT = pillar.wordpress.docroot -%}


{{ sls }} dir backup:
  file.directory:
    - name: {{ DOCROOT }}/backup
    - mode: '2770'
    - group: webdev
    - require:
      - file: wordpress docroot
      - group: user.webdevs webdev group


{{ sls }} backup script:
  file.managed:
    - name: /usr/local/bin/backup_wordpress.sh
    - source: salt://wordpress/files/backup_wordpress.sh
    - mode: '0555'


{{ sls }} daily backup cron job:
  cron.present:
    - name: '/usr/local/bin/backup_wordpress.sh {{ DOCROOT }} daily'
    - user: composer
    - identifier: backup_wordpress_daily
    - special: '@daily'
    - require:
      - file: {{ sls }} backup script
      - user: php_cc.composer user


{{ sls }} weekly backup cron job:
  cron.present:
    - name: '/usr/local/bin/backup_wordpress.sh {{ DOCROOT }} weekly'
    - user: composer
    - identifier: backup_wordpress_weekly
    - special: '@weekly'
    - require:
      - file: {{ sls }} backup script
      - user: php_cc.composer user
