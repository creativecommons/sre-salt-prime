include:
  - letsencrypt


letsencrypt:
  post_hooks:
    restart_nginx.sh: /usr/sbin/service nginx reload
nginx:
  flavor: light
states:
  nginx.redirects: {{ sls }}
