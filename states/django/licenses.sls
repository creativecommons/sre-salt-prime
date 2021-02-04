{# Database variables -#}
{% set DB_HOST = pillar.postgres.host -%}
{% set DJANGO_DB_USER = pillar.django.db_user -%}
{% set DJANGO_DB_PASS = pillar.django.db_pass -%}
{% set ROOT_DB_USER = pillar.postgres.root_user -%}
{% set ROOT_DB_PASS = pillar.postgres.root_pass -%}
{# Directory variables -#}
{% set DIR_PUBLIC = pillar.cc_licenses.public -%}
{% set DIR_LOG = pillar.cc_licenses.log -%}
{% set DIR_MEDIA = pillar.cc_licenses.media -%}
{% set DIR_REPO = pillar.cc_licenses.repo -%}
{% set DIR_STATIC = pillar.cc_licenses.static -%}
{% set DIR_STATIC_ORIGIN = pillar.cc_licenses.static_origin -%}
{% set DIR_VENV = pillar.cc_licenses.venv -%}
{# Misc variables -#}
{% set DOMAIN = "licenses" -%}
{% if pillar.pod.startswith("stage") -%}
{% set ENVIRONMENT = "staging" -%}
{% else -%}
{% set ENVIRONMENT = "production" -%}
{% endif -%}
{% set PORTFILE = pillar.cc_licenses.portfile -%}
{% set NOW = None|strftime("%Y%m%d_%H%M%S") -%}
{% set TRANS_DEPLOY_KEY = pillar.django.translation_repo_deploy_key -%}


include:
  - virtualenv


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git


{{ sls }} create {{ DJANGO_DB_USER }} postgres user:
  postgres_user.present:
    - name: {{ DJANGO_DB_USER }}
    - encrypted: True
    - login: True
    - password: {{ DJANGO_DB_PASS }}
    - refresh_password: True
    - db_host: {{ DB_HOST }}
    - db_user: {{ ROOT_DB_USER }}
    - db_password: {{ ROOT_DB_PASS }}
    - require:
      - file: postgres_cc.user_clusters append


{{ sls }} grant {{ DJANGO_DB_USER }} to {{ ROOT_DB_USER }}:
  postgres_privileges.present:
    - name: {{ ROOT_DB_USER }}
    - object_name: {{ DJANGO_DB_USER }}
    - object_type: group
    - grant_option: True
    - db_host: {{ DB_HOST }}
    - db_user: {{ ROOT_DB_USER }}
    - db_password: {{ ROOT_DB_PASS }}
    - require:
      - postgres_user: {{ sls }} create postgres user


{{ sls }} django postgres db:
  postgres_database.present:
    - name: {{ pillar.django.db }}
    - encoding: UTF8
    - lc_ctype: 'en_US.UTF-8'
    - lc_collate: 'en_US.UTF-8'
    - owner: {{ DJANGO_DB_USER }}
    - db_host: {{ DB_HOST }}
    - db_user: {{ ROOT_DB_USER }}
    - db_password: {{ ROOT_DB_PASS }}
    - require:
      - postgres_privileges: >-
          {{ sls }} grant {{ DJANGO_DB_USER }} to {{ ROOT_DB_USER }}


{{ sls }} cc-licenses repo:
  git.latest:
    - name: https://github.com/creativecommons/cc-licenses.git
    - target: {{ DIR_REPO }}
    - rev: develop
    - branch: develop
    - fetch_tags: False
    - require:
{%- if pillar.mounts %}
{%- for mount in pillar.mounts %}
      - mount: mount mount {{ mount.file }}
{%- endfor %}
{%- endif %}
      - pkg: {{ sls }} installed packages
      - postgres_database: {{ sls }} django postgres db


{{ sls }} public dir:
  file.directory:
    - name: {{ DIR_PUBLIC }}
    - owner: www-data
    - group: www-data
    - mode: '2775'
    - require:
      - git: {{ sls }} cc-licenses repo
      - pkg: nginx installed packages # nginx provides www-data group and user


{{ sls }} media dir:
  file.directory:
    - name: {{ DIR_MEDIA }}
    - owner: www-data
    - group: www-data
    - mode: '2775'
    - require:
      - file: {{ sls }} public dir
      - pkg: nginx installed packages # nginx provides www-data group and user


{{ sls }} static dir:
  file.directory:
    - name: {{ DIR_STATIC }}
    - owner: www-data
    - group: www-data
    - mode: '2775'
    - require:
      - file: {{ sls }} public dir
      - pkg: nginx installed packages # nginx provides www-data group and user


{{ sls }} log dir:
  file.directory:
    - name: {{ DIR_LOG }}
    - owner: www-data
    - group: www-data
    - mode: '2775'
    - require:
      - git: {{ sls }} cc-licenses repo
      - pkg: nginx installed packages # nginx provides www-data group and user


{{ sls }} virtualenv:
  virtualenv.managed:
    - name: {{ DIR_VENV }}
    - python: /usr/bin/python3
    - cwd: {{ DIR_REPO }}
    - require:
      - git: {{ sls }} cc-licenses repo


{{ sls }} requirements:
  pip.installed:
    - requirements: {{ DIR_REPO }}/requirements/production.txt
    - bin_env: {{ DIR_VENV }}
    - require:
      - virtualenv: {{ sls }} virtualenv


{%- for task in ["migrate", "collectstatic"] %}


{{ sls }} manage.py {{ task }}:
  cmd.run:
    - name: {{ DIR_VENV }}/bin/python manage.py {{ task }} --noinput
    - cwd: {{ DIR_REPO }}
    - env:
      - DATABASE_URL: {{ pillar.django.database_url }}
      - DJANGO_SECRET_KEY: {{ pillar.django.secret_key }}
      - DJANGO_SETTINGS_MODULE: cc_licenses.settings.deploy
      - DOMAIN: {{ DOMAIN }}
      - ENVIRONMENT: {{ ENVIRONMENT }}
      - MEDIA_ROOT: {{ DIR_MEDIA }}
      - STATIC_ROOT: {{ DIR_STATIC }}
    - require:
      - file: {{ sls }} static dir
      - pip: {{ sls }} requirements
    - onchanges:
      - git: {{ sls }} cc-licenses repo
{%- endfor %}


{{ sls }} run_django_admin.sh:
  file.managed:
    - name: {{ DIR_VENV }}/bin/run_django_admin.sh
    - mode: '0775'
    - contents:
      - "#!/bin/sh"
      - "# Managed by SaltStack: {{ sls }}"
      - "cd {{ DIR_REPO }}"
      - "export DATABASE_URL={{ pillar.django.database_url }}"
      - "export DJANGO_SECRET_KEY={{ pillar.django.secret_key }}"
      - "export DJANGO_SETTINGS_MODULE=cc_licenses.settings.deploy"
      - "export DOMAIN={{ DOMAIN }}"
      - "export ENVIRONMENT={{ ENVIRONMENT }}"
      - "export MEDIA_ROOT={{ DIR_MEDIA }}"
      - "export STATIC_ROOT={{ DIR_STATIC }}"
      - "export TRANSIFEX_API_TOKEN={{ pillar.django.transifex_api_token }}"
      - "export TRANSLATION_REPOSITORY_DEPLOY_KEY={{ TRANS_DEPLOY_KEY }}"
      - "sudo --preserve-env --set-home --user=www-data --group=www-data \\"
      - "    {{ DIR_VENV }}/bin/python \\"
      - "    manage.py \\"
      - "    \"${@}\""
    - require:
      - virtualenv: {{ sls }} virtualenv


{{ sls }} run_gunicorn.sh:
  file.managed:
    - name: {{ DIR_VENV }}/bin/run_gunicorn.sh
    - mode: '0775'
    - contents:
      - "#!/bin/sh"
      - "# Managed by SaltStack: {{ sls }}"
      - "cd {{ DIR_REPO }}"
      - "export DATABASE_URL={{ pillar.django.database_url }}"
      - "export DJANGO_SECRET_KEY={{ pillar.django.secret_key }}"
      - "export DJANGO_SETTINGS_MODULE=cc_licenses.settings.deploy"
      - "export DOMAIN={{ DOMAIN }}"
      - "export ENVIRONMENT={{ ENVIRONMENT }}"
      - "export MEDIA_ROOT={{ DIR_MEDIA }}"
      - "export STATIC_ROOT={{ DIR_STATIC }}"
      - "export TRANSIFEX_API_TOKEN={{ pillar.django.transifex_api_token }}"
      - "export TRANSLATION_REPOSITORY_DEPLOY_KEY={{ TRANS_DEPLOY_KEY }}"
      - "if [ -S {{ PORTFILE }} ]; then"
      - "    echo 'ERROR: gunicorn is already running' 1>&2"
      - "    exit 1"
      - "fi"
      - "sudo --preserve-env --set-home --user=www-data --group=www-data \\"
      - "    {{ DIR_VENV }}/bin/gunicorn \\"
      - "    --bind unix:{{ PORTFILE }} \\"
      - "    --error-logfile={{ DIR_LOG }}/gunicorn.log --capture-output \\"
      - "    cc_licenses.wsgi &"
    - require:
      - file: {{ sls }} log dir
      - virtualenv: {{ sls }} virtualenv


{{ sls }} execute run_gunicorn.sh:
  cmd.run:
    - name: {{ DIR_VENV }}/bin/run_gunicorn.sh
    - cwd: {{ DIR_REPO }}
    - bg: True
    - require:
      - cmd: {{ sls }} manage.py collectstatic
      - cmd: {{ sls }} manage.py migrate
      - file: {{ sls }} run_gunicorn.sh
    - unless:
      - test -S {{ PORTFILE }}
