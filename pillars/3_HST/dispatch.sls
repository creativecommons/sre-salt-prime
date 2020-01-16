include:
  - letsencrypt


letsencrypt:
  post_hooks:
    restart_nginx.sh: /usr/sbin/service nginx reload
states:
  nginx.dispatch: {{ sls }}
nginx:
  flavor: light
