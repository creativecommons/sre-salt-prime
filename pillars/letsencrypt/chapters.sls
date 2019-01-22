letsencrypt:
  deploy_hooks:
    restart_nginx.sh: service apache2 reload
  domainsets:
    chapters:
      - chapters.creativecommons.org
