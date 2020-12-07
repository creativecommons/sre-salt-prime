# https://github.com/discourse/discourse/blob/master/docs/INSTALL-cloud.md
{% set ADMIN_EMAILS = [] -%}
{%- for account in pillar.user.admins.keys()|sort %}
{%- set _ = ADMIN_EMAILS.append(pillar.user.admins[account]["mail"]) %}
{%- endfor %}
{% set DEV_EMAILS = ",".join(ADMIN_EMAILS + pillar.discourse.dev_emails) -%}


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
        DEVELOPER_EMAILS: {{ DEV_EMAILS }}
        SMTP_ADDRESS: {{ pillar.postfix.onlyhost }}
        SMTP_USER_NAME: {{ pillar.postfix.relayuser }}
        SMTP_PASSWORD: {{ pillar.postfix.relaypass }}
        LETSENCRYPT_EMAIL: {{ pillar.letsencrypt.config.email }}
    - require:
      - git: {{ sls }} discourse repo clone
