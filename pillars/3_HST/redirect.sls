include:
  - letsencrypt


letsencrypt:
  deploy_hooks:
    restart_nginx.sh: /usr/sbin/service nginx reload
nginx:
  flavor: light
