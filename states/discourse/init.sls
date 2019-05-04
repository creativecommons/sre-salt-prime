# https://github.com/discourse/discourse/blob/master/docs/INSTALL-cloud.md


include:
  - docker


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git
    - require:
      - pkg: docker installed packages


{{ sls }} discourse repo clone:
  git.cloned:
    - name: https://github.com/discourse/discourse_docker
    - target: /srv/discourse
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} discourse app config:
  file.managed:
    - name: /srv/discourse/containers/app.yml
    - source: salt://discourse/files/app.yml
    - mode: '0440'
    - template: jinja
    - defaults:
        HOSTNAME: {{ pillar.discourse.hostname }}
        DEVELOPER_EMAILS: {{ pillar.discourse.dev_emails }}
        SMTP_ADDRESS: {{ pillar.postfix.onlyhost }}
        SMTP_USER_NAME: {{ pillar.postfix.relayuser }}
        SMTP_PASSWORD: {{ pillar.postfix.relaypass }}
        LETSENCRYPT_EMAIL: {{ pillar.letsencrypt.config.email }}
    - require:
      - git: {{ sls }} discourse repo clone
