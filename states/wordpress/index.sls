{% set POD = pillar.pod -%}
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set GIT = "/var/www/git" -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set PLUGINS = "{}/plugins".format(WP_CONTENT) -%}
{% set THEMES = "{}/themes".format(WP_CONTENT) -%}
{% set STAGE_USER = salt.pillar.get("apache2:stage_username", false) -%}
{% set STAGE_PASS = salt.pillar.get("apache2:stage_password", false) -%}


{% if POD.startswith("stage") -%}
{{ sls }} disallow robots:
  file.managed:
    - name: {{ DOCROOT }}/robots.txt
    - contents:
      - 'User-agent: *'
      - 'Disallow: /'
    - mode: '0400'
    - require:
      - file: wordpress docroot
    - require_in:
      - cmd: wordpress WordPress install
{%- endif %}


{% if STAGE_USER and STAGE_PASS -%}
{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - apache2-utils
    - require:
      - pkg: apache2 installed packages


{{ sls }} basic authentication user file:
  file.managed:
    - name: /var/www/htpasswd
    - source: ~
    - group: www-data
    - mode: '0440'
    - replace: False
    - require:
      - pkg: {{ sls }} installed packages


{{ sls }} basic authentication user exists:
  webutil.user_exists:
    - name: {{ STAGE_USER }}
    - password: {{ STAGE_PASS }}
    - htpasswd_file: /var/www/htpasswd
    - options: s
    - update: True
    - require:
      - file: {{ sls }} basic authentication user file
    - require_in:
      - cmd: wordpress WordPress install
{%- endif %}


{{ sls }} {{ GIT }} directory:
  file.directory:
    - name: {{ GIT }}
    - mode: '2775'
    - group: webdev
    - require:
      - file: wordpress docroot
      - pkg: {{ sls }} installed packages


{%- for repo in ("cc-legal-tools-data", "faq", "mp") %}


{{ sls }} {{ repo }} repo:
  git.latest:
    - name: 'https://github.com/creativecommons/{{ repo }}.git'
    - target: {{ GIT }}/{{ repo }}
    - rev: {{ pillar.index.branch }}
    - branch: {{ pillar.index.branch }}
    - user: composer
    - fetch_tags: False
    - require:
      - file: {{ sls }} {{ GIT }} directory
 
{#- commented as it changes all file permissions leading to issue while 
 #  updating the repo
{{ sls }} {{ repo }} permissions:
  file.directory:
    - name: {{ GIT }}/{{ repo }}
    - dir_mode: '2775'
    - file_mode: '0664'
    - group: webdev
    - recurse:
      - mode
      - group
    - require:
      - git: {{ sls }} {{ repo }} repo
#}
{%- endfor %}
