# for plugins and themes that are not available to be installed via composer
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set GIT = "/var/www/git" -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}


{{ sls }} installed packages:
  pkg.installed:
    - pkgs:
      - git
    - require:
      - file: wordpress symlink wp-content


{{ sls }} {{ GIT }} directory:
  file.directory:
    - name: {{ GIT }}
    - mode: '2775'
    - group: webdev
    - require:
      - pkg: {{ sls }} installed packages


{%- for resource in pillar.wordpress.git_install %}
{%- set target = resource["target"] %}
{%- set rev = resource["rev"] %}
{%- set type = resource["type"] %}
{%- set repo = resource["repo"] %}


{{ sls }} {{ target }} repo:
  git.latest:
    - name: {{ repo }}
    - target: {{ GIT }}/{{ target }}
    - rev: {{ rev }}
    - branch: {{ rev }}
    - user: composer
    - fetch_tags: False
    - require:
      - file: {{ sls }} {{ GIT }} directory


{{ sls }} {{ target }} permissions:
  file.directory:
    - name: {{ GIT }}/{{ target }}
    - dir_mode: '2775'
    - file_mode: '0664'
    - group: webdev
    - recurse:
      - mode
      - group
    - require:
      - git: {{ sls }} {{ target }} repo


{{ sls }} advanced-custom-fields-pro install:
  file.symlink:
    - name: {{ WP_CONTENT }}/{{ type }}/{{ target }}
    - target: {{ GIT }}/{{ target }}
    - force: True
    - require:
      - git: {{ sls }} {{ target }} repo
{%- endfor %}
