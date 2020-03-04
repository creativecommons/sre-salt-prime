{{ sls }} nginx_custom_logs:
  file.managed:
    - name: /etc/logrotate.d/nginx_custom_logs
    - source: salt://logrotate/files/nginx_custom_logs
    - mode: '0444'
    - template: jinja
    - defaults:
        SLS: {{ sls }}
        LOG_DIR: {{ pillar.nginx.custom_log_dir }}
