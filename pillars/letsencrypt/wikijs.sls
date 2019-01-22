letsencrypt:
  deploy_hooks:
    restart_nginx.sh: service nginx reload
  domainsets:
    wikijs:
      - wikijs.creativecommons.org
